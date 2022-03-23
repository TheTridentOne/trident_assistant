# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to transfer to Trident MTG
    class Order < Base
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      desc "sell", "sell NFT at fixed price"
      def ask; end

      desc "auction", "auction NFT"
      def auction; end

      desc "bid", "bid NFT"
      def bid; end

      desc "accept", "accept order"
      def accept; end

      desc "cancel", "cancel order"
      def cancel; end

      desc "deposit TOKEN ", "deposit NFT"
      def deposit; end

      desc "withdraw TOKEN", "withdraw NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def withdraw(token)
        memo = Utils::Memo.new(type: "W", token_id: token)
        payment =
          bot.create_multisig_transaction(
            keystore[:pin],
            asset_id: EXCHANGE_ASSET_ID,
            amount: MINIMUM_AMOUNT,
            receivers: Utils::TRIDENT_MTG[:members],
            threshold: Utils::TRIDENT_MTG[:threshold],
            memo: Utils::Memo.new(type: "W", token_id: token).encode,
            trace_id: SecureRandom.uuid
          )

        log UI.fmt("{{v}} payment: #{payment}")
      end

      desc "airdrop TOKEN", "airdrop NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      option :receiver, type: :string, aliases: "r", required: false, desc: "receiver ID of airdrop"
      option :start, type: :string, aliases: "s", required: false, desc: "start time of airdrop"
      option :expire, type: :string, aliases: "e", required: false, desc: "expire time of airdrop"
      def airdrop(token)
        collectible = bot.collectibles["data"].find(&->(c) { c["token_id"] == token && c["state"] != "spent" })
        raise "Cannot find NFT in wallet" if collectible.blank?

        log UI.fmt("{{v}} find collectible")

        memo = Utils::Memo.new(type: "AD").encode
        nfo = MixinBot::Utils::Nfo.new extra: memo.unpack1("H*")

        tx =
          if collectible["state"] == "signed"
            collectible["signed_tx"]
          else
            raw = bot.build_collectible_transaction(
              collectible: collectible,
              receivers: Utils::TRIDENT_MTG[:members],
              receivers_threshold: Utils::TRIDENT_MTG[:threshold],
              nfo: nfo.encode.hex
            )
            bot.sign_raw_transaction raw
          end

        request = bot.create_sign_collectible_request tx
        sign = bot.sign_collectible_request request["request_id"], keystore[:pin]
        result = bot.send_raw_transaction sign["raw_transaction"]

        log UI.fmt("{{v}} successfully transfer NFT")
        log result
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end
    end
  end
end
