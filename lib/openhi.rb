require "openhi/version"

module Openhi
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'digest/md5'
  require 'cgi'
  require 'openssl'
  require 'open64'
  require 'rexml/document'

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

  class OpenHiSDK
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

    end

    def create_room(opts = {})
      opts.merge!({:partner_id => @partner_id})
      doc = do_request("/rooms/create.xml", opts)
      if not doc.get_element('Errors').empty?
        raise OpenHiException.new doc.get_elements('Errors')[0].get_elements('error')[0].children[0].to_s
      end
      OpenHi::Room.new(doc.root.get_elements('Room')[0].get_elements('room_id')[0].children[0].to_s
    end

    protected

    def sign_string(data, secret)
      OpenSSL::HMAC.hexdigest(DIGEST, secret, data)
    end

    def do_request(api_url, params, token = nil)

    end

  end
end
