OpenHi
======

OpenHi is an API for creating and joining online classrooms. It was developed by [Hi!China](www.hichinaschool.com) for its own use and there is still no plan to open the platform.

Installation
------------

To install using bundler, add OpenHi to your `gemfile` and run `bundle install`:

    gem 'openhi', :git => 'git://github.com/vstabile/openhi.git'

How it works
------------

### Parnet ID and secret

We intend to open our platform at some point, but for now it's only used to give Mandarin lessons by [Hi!China](www.hichinaschool.com). If you're interested in using our platform please send us an e-mail to <contact@hichinaschool.com>.

### Create a classroom

Use the following code to create a classroom and get it's `room_id` back:

    partner_id = 0       # number
    secret = ''          # string
  
    openhi = OpenHi::API.new partner_id, secret

    course               # number
    level                # number
    lesson               # number
    json                 # string containing json data

    room_id = openhi.create_room :course => course, :level => level, :lesson => lesson, :json => json

### Create tokens

Once you have a `room_id`, you can generate tokens used to join the classroom:

    room_id               # number, returned by openhi.create_room
    role                  # string, 'host' or 'attendee'
    user_id               # number, user's identification in your system
    name                  # string, user's name
    skype                 # string, user's skype name if available

    openhi.generate_token :room_id => room_id, :role => role, :user_id => user_id, :name => name, :skype => skype
