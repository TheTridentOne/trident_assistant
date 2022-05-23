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
    end

    def get(path, **options)
      request(:get, path, **options)
    end

    def post(path, **options)
      request(:post, path, **options)
    end

    def put(path, **options)
      request(:put, path, **options)
    end

    private

    def request(verb, path, **options)
      uri = uri_for path

      options[:headers] ||= {}
      options[:headers]["Content-Type"] ||= "application/json"

      begin
        response = HTTP.timeout(connect: 5, write: 10, read: 10).request(verb, uri, options)
      rescue HTTP::Error => e
        raise HttpError, e.message
      end

      raise RequestError, response.to_s unless response.status.success?

      parse_response(response) do |parse_as, result|
        case parse_as
        when :json
          break result if result.is_a?(Array) || (result.is_a?(Hash) && result["message"].blank?)

          raise result["message"]
        else
          result
        end
      end
    end

    def uri_for(path)
      uri_options = {
        scheme: endpoint.scheme,
        host: endpoint.host,
        port: endpoint.port,
        path: path
      }
      Addressable::URI.new(uri_options)
    end

    def parse_response(response)
      content_type = response.headers[:content_type]
      parse_as = {
        %r{^application/json} => :json,
        %r{^image/.*} => :file,
        %r{^text/html} => :xml,
        %r{^text/plain} => :plain
      }.each_with_object([]) { |match, memo| memo << match[1] if content_type =~ match[0] }.first || :plain

      if parse_as == :plain
        result = JSON.parse(response&.body&.to_s)
        result && yield(:json, result)

        yield(:plain, response.body)
      end

      case parse_as
      when :json
        result = JSON.parse(response.body.to_s)
      when :file
        extension =
          if response.headers[:content_type] =~ %r{^image/.*}
            {
              "image/gif": ".gif",
              "image/jpeg": ".jpg",
              "image/png": ".png"
            }[response.headers["content-type"]]
          else
            ""
          end

        begin
          file = Tempfile.new(["mixin-file-", extension])
          file.binmode
          file.write(response.body)
        ensure
          file&.close
        end

        result = file
      when :xml
        result = Hash.from_xml(response.body.to_s)
      else
        result = response.body
      end

      yield(parse_as, result)
    end
  end
end
