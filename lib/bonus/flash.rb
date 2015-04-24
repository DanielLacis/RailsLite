require 'json'
require 'webrick'
require 'byebug'

module BonusPhase
  class Flash
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @cookie_key = '_rails_lite_app_flash'
      @cookies = req.cookies
      @cookies.each do |cookie|
        if cookie.name == @cookie_key
          @cookie = JSON.parse(cookie.value)
        end
      end
      if @cookie
        set_ivars
      else
        new_cookie
      end
      @flag = false
    end

    def now
      @flag = true
      self
    end

    def [](key)
      @flash_hash[key]
    end

    def []=(key, val)
      @flash_hash[key] = val
      @flash_keys << key
      @discard.delete(key)
      if @flag
        flag = false
        @discard << key
      end
    end

    def update_flash
      @discard_keys.each do |disc|
        @flash_hash.delete(disc)
      end
      @discard_keys, @flash_keys = @flash_keys, []
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_flash(res)
      update_flash
      res.cookies <<  WEBrick::Cookie.new(@cookie_key, @cookie.to_json)
    end

    private

    def new_cookie
      @cookie = {}
      @flash_keys = []
      @discard_keys = []
      @flash_hash = {}
      @cookie[:flash_keys] = @flash_keys
      @cookie[:discard_keys] = @discard_keys
      @cookie[:flash_hash] = @flash_hash
    end

    def set_ivars
      @flash_keys = @cookie[:flash_keys]
      @discard_keys = @cookie[:discard_keys]
      @flash_hash = @cookie[:flash_hash]
    end
  end

  class ControllerBase < Phase6::ControllerBase
    helper_method :link_to, :button_to, :form_authenticity_token

    before_action :form_authenticity_token

    def link_to(text, url, method)
      html = <<-HTML
        <a href="#{text}">#{url}</a>
      HTML
      html.html_safe
    end

    def button_to(text, url, method = "get")
      html = <<-HTML
        <form action="#{url}" method="get">
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
          <input type="hidden" value="#{method}">
          <input type="submit" value="#{text}">
        </form>
      HTML
      html.html_safe
    end

    def form_authenticity_token
      token ||= SecureRandom.urlsafe_base64
    end
  end
end
