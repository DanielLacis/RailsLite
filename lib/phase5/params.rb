require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      query_raw = req.query_string
      body_raw = req.body
      parse_www_encoded_form(query_raw) unless query_raw.nil?
      parse_www_encoded_form(body_raw) unless body_raw.nil?
      @params = @params.merge(route_params)
    end

    def [](key)
      if key.is_a?(Symbol)
        return @params[key.to_s]
      end
      @params[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      # pairs = URI.decode_www_form(www_encoded_form)
      # pairs.each do |pair|
      #   @params[pair[0]] = pair[1]
      # end

      # this only handles a single hash, not very useful
      pairs = URI.decode_www_form(www_encoded_form)

      pairs.each do |pair|
        parsed_keys = parse_key(pair[0])
        if parsed_keys.length == 1
          @params[pair[0]] = pair[1]
        else
          current = {}

          flag = true
          count = 0
          parsed_keys[0..-2].each do |key|
            if flag
              @params[key] ||= {}
              flag = false
              current = @params[key]
            else
              current[key] ||= {}
              current = current[key]
            end
            count += 1
          end
          current[parsed_keys[-1]] = pair[1]
        end
      end

      # pairs = URI.decode_www_form(www_encoded_form)
      # count = 0
      # pairs.each do |pair|
      #   debugger if count > 0
      #   parsed_keys = parse_key(pair[0])
      #   if parsed_keys.length == 1
      #     @params[pair[0]] = pair[1]
      #   else
      #     @params[parsed_keys[0]] = {}
      #     current = @params[parsed_keys[0]]
      #
      #     parsed_keys[1..-2].each do |key|
      #       current[key] = {}
      #       current = current[key]
      #     end
      #     current[parsed_keys[-1]] = pair[1]
      #   end
      #   count += 1
      # end

      #
      # pairs = URI.decode_www_form(www_encoded_form)
      #
      # pairs.each do |pair|
      #   key_set = parse_key(pair[0])
      #   @params = @params.merge(hash_recursion(key_set, pair[1]))
      # end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end

    def hash_recursion(key_set, value)
      return {key_set[0] => value} if key_set.length == 1
      { key_set[0] => hash_recursion(key_set[1..-1], value) }
    end
  end
end
