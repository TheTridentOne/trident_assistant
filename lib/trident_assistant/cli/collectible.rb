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

      desc "show UUID", "query collectible"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def show(uuid)
        r = api.mixin_bot.collectible uuid

        log r["data"]
      end

      desc "deposit TOKEN", "deposit NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def deposit(token)
        log api.deposit token
        log UI.fmt("{{v}} successfully transfer NFT")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end

      desc "airdrop TOKEN", "airdrop NFT"
      option :receiver, type: :string, aliases: "r", required: false, desc: "receiver ID of airdrop"
      option :start, type: :string, aliases: "s", required: false, desc: "start time of airdrop"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def airdrop(token)
        log api.airdrop token, receiver_id: options[:receiver], start_at: options[:start]
        log UI.fmt("{{v}} successfully transfer NFT")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end

      desc "withdraw TOKEN", "withdraw NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def withdraw(token)
        log api.withdraw token
        log UI.fmt("{{v}} successfully invoked withdraw")
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end
    end
  end
end
