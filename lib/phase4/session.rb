require 'json'
require 'webrick'
require 'byebug'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @app_key = '_rails_lite_app'
      @cookies = req.cookies
      @cookies.each do |cookie|
        if cookie.name == @app_key
          @cookie = JSON.parse(cookie.value)
        end
      end
      @cookie ||= {}
    end

    def [](key)

      @cookie[key]
    end

    def []=(key, val)
      @cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies <<  WEBrick::Cookie.new(@app_key, @cookie.to_json)
    end
  end
end
