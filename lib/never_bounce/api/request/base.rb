
require "never_bounce/api/feature/basic_initialize"
require "never_bounce/api/feature/require_attr"

module NeverBounce; module API; module Request
  # @abstract
  # @see API::Feature::BasicInitialize
  class Base
    API::Feature::BasicInitialize.load(self)
    API::Feature::RequireAttr.load(self)

    # User's API key.
    # @return [String]
    attr_accessor :api_key
    attr_writer :api_url, :headers, :user_agent

    # Custom API URL. Default is <tt>https://api.neverbounce.com/v4</tt>.
    # @return [String]
    def api_url
      @api_url ||= "https://api.neverbounce.com/v4"
    end

    # @!attribute headers
    # @return [Array]
    def headers
      {
        "Content-Type" => "application/json",
        "User-Agent" => user_agent,
      }
    end

    # <tt>:get</tt>, <tt>:post</tt> or whatever.
    # @abstract
    # @return [Symbol]
    # @return [String]
    def self.http_method
      raise NotImplementedError, "Redefine `self.http_method` in your class: #{self}"
    end

    # Request path on server, e.g. <tt>"jobs/parse"</tt>.
    # @abstract
    # @return [String]
    def self.path
      raise NotImplementedError, "Redefine `self.path` in your class: #{self}"
    end

    # @abstract
    # @return [Class]
    def self.response_klass
      raise NotImplementedError, "Redefine `self.response_klass` in your class: #{self}"
    end

    # Build arguments for cURL OS command.
    # @return [Array]
    def to_curl
      # NOTE: I consider we should use long options to avoid ambiguity of ones like `-u` etc.
      @curl ||= begin
        ar = [
          "--request", self.class.http_method.to_s.upcase,
          "--url", "#{api_url}/#{self.class.path}",
        ]

        ar += headers.reject { |k,| k == "User-Agent" }.flat_map do |k, v|
          ["--header", "#{k}: #{v}"]
        end

        ar += ["--data-binary", to_h.to_json]

        ar
      end
    end

    # Build a <tt>Hash</tt> representation of request data.
    # @abstract
    # @return [Hash]
    def to_h
      raise NotImplementedError, "Redefine `to_h` in your class: #{self.class}"
    end

    # Build argumentsfor <tt>Httparty</tt> invocation.
    # @return [Array]
    def to_httparty
      [
        self.class.http_method,   # E.g. `:get`.
        "#{api_url}/#{self.class.path}",
        {
          body: to_h.to_json,
          headers: headers,
        }
      ]
    end

    # @!attribute user_agent
    # @return [String]
    def user_agent
      @user_agent ||= [
        "NeverBounceApi-Ruby/#{API::VERSION} (#{RUBY_PLATFORM})",
        "Ruby/#{RUBY_VERSION} (p #{RUBY_PATCHLEVEL}; rev #{RUBY_REVISION})",
      ].join(" ")
    end
  end
end; end; end
