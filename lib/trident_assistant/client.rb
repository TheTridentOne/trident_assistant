# frozen_string_literal: true

module TridentAssistant
  # HTTP client to trident server
  class Client
    class HttpError < TridentAssistant::Error; end
    class RequestError < TridentAssistant::Error; end

    ENDPOINT = "https://thetrident.one"

    attr_reader :endpoint

    def initialize(**kwargs)
      @endpoint = URI(kwargs[:endpoint] || ENDPOINT)
      @conn = Faraday.new(url: @endpoint.to_s) do |f|
        f.request :json
        f.request :retry
        f.response :raise_error
        f.response :json
        f.response :logger if kwargs[:debug]
      end
    end

    def get(path, params = nil, headers = nil)
      @conn.get(path, params&.compact, headers).body
    end

    def post(path, body = nil, headers = nil)
      @conn.post(path, body&.compact, headers).body
    end

    def put(path, body = nil, headers = nil)
      @conn.post(path, body&.compact, headers).body
    end
  end
end
