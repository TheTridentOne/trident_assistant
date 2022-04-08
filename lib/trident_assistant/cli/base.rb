# frozen_string_literal: true

require_relative "../api"

module TridentAssistant
  module CLI
    # Base class of CLI
    class Base < Thor
      # https://github.com/Shopify/cli-ui
      UI = ::CLI::UI

      attr_reader :keystore, :bot, :client, :api

      def initialize(*args)
        super

        endpoint = options[:endpoint] || "https://thetrident.one"

        @api =
          begin
            TridentAssistant::API.new(
              endpoint: endpoint,
              keystore: options[:keystore]
            )
          rescue JSON::ParserError
            log UI.fmt("{{x}} falied to parse keystore.json: #{options[:keystore]}")
          rescue StandardError => e
            log UI.fmt "{{x}} Failed to initialize Mixin bot, maybe your keystore is incorrect. #{e.inspect}"
          end
      end

      private

      def log(obj)
        if options[:pretty]
          if obj.is_a? String
            puts obj
          else
            ap obj
          end
        else
          puts obj.inspect
        end
      end
    end
  end
end
