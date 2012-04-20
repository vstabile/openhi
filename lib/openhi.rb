require "openhi/version"
require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'digest/md5'
require 'cgi'
require 'openssl'
require 'base64'
require 'rexml/document'
  
Net::HTTP.version_1_2
  
require 'monkey_patches'

module OpenHi
  API_URL = "http://localhost/hichinaschool.com/openhi";

  DIGEST = OpenSSL::Digest::Digest.new('sha1')

  # Exception thrown when parter id and secret are invalid
  class OpenHiException < RuntimeError
  end

  # Room object containing the room_id
  class Room
    attr_reader :room_id

    def initialize(room_id)
      @room_id = room_id
    end

    def to_s
      room_id
    end
  end

  # Roles
  class RoleConstants
    HOST     = "host"
    ATTENDEE = "attendee"
  end

  class API
    attr_accessor :api_url
  
    @@TOKEN_SALT = "T1=="

    def initialize(partner_id, secret, options = nil)
      @partner_id = partner_id
      @secret = secret

      if options.is_a?(::Hash)
        @api_url = options[:api_url] || API_URL
      end

      unless @api_url
        @api_url = API_URL
      end
    end

    def generate_token(opts = {})
      { :room_id => '', :role => RoleConstants::ATTENDEE, :user_id => nil, :name => '', :skype => '', :expire_time => nil }.merge!(opts)
      
      unless opts[:role] == RoleConstants::ATTENDEE || opts[:role] == RoleConstants::HOST
        raise OpenHiException.new "'#{opts[:role]}' is not defined as a role"
      end

      data_params = {
				:room_id => opts[:room_id],
        :role => opts[:role],
        :uid => opts[:user_id],
        :name => opts[:name],
        :skype => opts[:skype],
        :create_time => Time.now.to_i
      }
      
      unless opts[:expire_time].nil?
				raise OpenHiException.new 'expire_time must be a number' if not opts[:expire_time].is_a?(Numeric)
        raise OpenHiException.new 'expire_time must be in the future' if opts[:expire_time] < Time.now.to_i
        raise OpenHiException.new 'expire_time must be in the next 7 days' if opts[:expire_time] > (Time.now.to_i + 604800)
        data_params[:expire_time] = opts[:expire_time].to_i
      end
      
      data_string = data_params.urlencode
      
      sig = sign_string(data_string, @secret)
      
      meta_string = {
				:partner_id => @partner_id,
				:sig => sig
      }.urlencode
      
      @@TOKEN_SALT + Base64.encode64(meta_string + ":" + data_string).gsub("\n", '')
    end

    def create_room(opts = {})
      opts.merge!({ :partner_id => @partner_id })
      
      opts[:content] = "#{opts[:course]}-#{opts[:level]}-#{opts[:lesson]}" if opts[:content].blank?
      
      doc = do_request("/rooms/create.xml", opts)
      if not doc.get_elements('Errors').empty?
        raise OpenHiException.new doc.get_elements('Errors')[0].get_elements('error')[0].children[0].to_s
      end
      OpenHi::Room.new(doc.root.get_elements('room')[0].get_elements('room_id')[0].children[0].to_s)
    end

    protected

    def sign_string(data, secret)
      OpenSSL::HMAC.hexdigest(DIGEST, secret, data)
    end

    def do_request(url, params)
      url = URI.parse(@api_url + url)
      if params.empty?
				req = Net::HTTP::Get.new(url.to_s)
      else
        req = Net::HTTP::Post.new(url.to_s)
        req.set_form_data(params)
      end

			credentials = Base64.encode64("#{@partner_id}:#{@secret}").gsub("\n", '')
      req.add_field 'Authorization', "Basic #{credentials}"
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if @api_url.start_with?("https")
      res = http.start { |http| http.request(req) }
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          doc = REXML::Document.new(res.read_body)
          return doc
        else
          res.error!
        end
    rescue Net::HTTPExceptions
      raise
      raise OpenHiException.new 'HTTP Exceptions'
    rescue NoMethodError
      raise
      raise OpenHiException.new 'No Method Error'
    end
  end
end
