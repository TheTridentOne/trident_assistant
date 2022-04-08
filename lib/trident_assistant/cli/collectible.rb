# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to query Trident and Mixin APIs
    class Collectible < Base
      desc "index", "query collectibles in wallet"
      option :state, type: :string, aliases: "s", required: false, default: :unspent,
                     desc: "keystore or keystore.json file of Mixin bot"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def index
        r = api.mixin_bot.collectibles state: options[:state]

        log r["data"]
      end

      desc "show COLLECTION TOKEN", "query collectible"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def show(collection, token)
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        r = api.mixin_bot.collectible token_id

        log r["data"]
      end

      desc "deposit COLLECTION TOKEN", "deposit NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def deposit(collection, token)
        log api.deposit collection, token
        log UI.fmt("{{v}} successfully transfer NFT")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end

      desc "airdrop COLLECTION, TOKEN", "airdrop NFT"
      option :receiver, type: :string, aliases: "r", required: false, desc: "receiver ID of airdrop"
      option :start, type: :string, aliases: "s", required: false, desc: "start time of airdrop"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def airdrop(collection, token)
        log api.airdrop collection, token, receiver_id: options[:receiver], start_at: options[:start]
        log UI.fmt("{{v}} successfully transfer NFT")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end

      desc "withdraw COLLECTION TOKEN", "withdraw NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def withdraw(collection, token)
        log api.withdraw collection, token
        log UI.fmt("{{v}} successfully invoked withdraw")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end

      desc "bulkairdrop DIR", "Airdrop NFT in bulk"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def bulkairdrop(dir)
        raise "#{dir} is not a directory" unless Dir.exist?(dir)

        Dir.glob("#{dir}/*.json").each do |file|
          log UI.fmt("{{v}} found #{file}")
          data = TridentAssistant::Utils.parse_json file
          metadata = TridentAssistant::Utils.parse_metadata data
          log UI.fmt("{{v}} metadata parsed")
          metadata.validate!
          log UI.fmt("{{v}} metadata validated")

          if data.dig("_airdrop", "hash").present?
            log UI.fmt("{{v}} NFT already transferred")
            next
          end

          receiver_id = data.dig("_airdrop", "receiver_id")
          start_at = data.dig("_airdrop", "start_at")
          log UI.fmt("{{v}} airdrop receiver_id: #{receiver_id}")
          log UI.fmt("{{v}} airdrop start_at: #{start_at}")

          r = api.airdrop metadata.collection["id"], metadata.token["id"], receiver_id: receiver_id, start_at: start_at
          log r["data"]
          data["_airdrop"] ||= {}
          data["_airdrop"]["hash"] = r["data"]["hash"]
          log UI.fmt("{{v}} successfully transfer NFT ##{metadata.token["id"]} #{metadata.collection["id"]}")
        rescue TridentAssistant::Utils::Metadata::InvalidFormatError, JSON::ParserError, Client::RequestError,
               MixinBot::Error, RuntimeError => e
          log UI.fmt("{{x}} #{file} failed to airdrop: #{e.inspect}")
          next
        ensure
          File.write file, data.to_json
        end
      end

      private

      def _airdrop; end
    end
  end
end
