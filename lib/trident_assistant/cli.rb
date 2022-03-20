# frozen_string_literal: true

require_relative "./client"
require_relative "./cli/api"
require_relative "./cli/metadata"
require_relative "./cli/mint"
require_relative "./cli/utils"

module TridentAssistant
  # CLI tool
  class CLI < Thor
    # https://github.com/Shopify/cli-ui
    UI = ::CLI::UI

    class_option :endpoint, type: :string, aliases: "-e", default: "thetrident.one", desc: "Specify trident endpoint"
    class_option :pretty, type: :boolean, aliases: "-r", default: true, desc: "Print output in pretty"

    attr_reader :keystore, :bot, :client

    def initialize(*args)
      super
      @client = Client.new host: options[:endpoint]

      return if options[:keystore].blank?

      @bot =
        begin
          @keystore = Utils.parse_json options[:keystore]
          Utils.mixin_bot_from_keystore @keystore
        rescue JSON::ParserError
          log UI.fmt("{{x}} falied to parse keystore.json: #{options[:keystore]}")
        rescue StandardError => e
          log UI.fmt "{{x}} Failed to initialize Mixin bot, maybe your keystore is incorrect. #{e.inspect}"
        end
    end

    desc "version", "Display TridentAssistant version"
    def version
      log VERSION
    end

    def self.exit_on_failure?
      true
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
