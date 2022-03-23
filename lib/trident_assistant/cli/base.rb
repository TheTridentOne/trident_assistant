# frozen_string_literal: true

require_relative "../client"

module TridentAssistant
  # CLI base class
  module CLI
    class Base < Thor
      attr_reader :keystore, :bot, :client

      def initialize(*args)
        super
        @client = Client.new endpoint: options[:endpoint]

        return if options[:keystore].blank?

        @bot =
          begin
            @keystore = TridentAssistant::Utils.parse_json options[:keystore]
            TridentAssistant::Utils.mixin_bot_from_keystore @keystore
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
