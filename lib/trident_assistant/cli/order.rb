# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to transfer to Trident MTG
    class Order < Base
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      desc "index", "list orders"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      option :collection, type: :string, aliases: "c", required: false, desc: "collection ID"
      option :metahash, type: :string, aliases: "m", required: false, desc: "metahash"
      option :type, type: :string, aliases: "t", required: false, desc: "ask | bid | auction"
      option :state, type: :string, aliases: "s", required: false, desc: "open | completed"
      def index
        log api.orders(
          collection_id: options[:collection],
          metahash: options[:metahash],
          state: options[:state],
          type: options[:type]
        )
      end

      desc "show ID", "query order"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def show(id)
        log api.order id
      end

      desc "sell", "sell NFT at fixed price"
      def ask; end

      desc "auction", "auction NFT"
      def auction; end

      desc "bid", "bid NFT"
      def bid; end

      desc "fill", "fill order"
      option :id, type: :string, aliases: "i", required: true, desc: "order ID"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def fill
        order = api.order options[:id]

        if order["state"] != "open"
          log UI.fmt("{{x}} order #{order["state"]}")
          return
        end

        memo = TridentAssistant::Utils::Memo.new(type: "F", order_id: options[:id], token_id: order["token_id"])
        log memo.json

        trace_id = SecureRandom.uuid
        payment =
          api.mixin_bot.create_multisig_transaction(
            keystore[:pin],
            {
              asset_id: order["asset_id"],
              trace_id: trace_id,
              amount: order["price"],
              memo: memo.encode,
              receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
              threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
            }
          )

        log UI.fmt("{{v}} NFT mint payment paid: #{payment["data"]}") if payment["errors"].blank?
      end

      desc "cancel", "cancel order"
      def cancel; end

      desc "deposit TOKEN", "deposit NFT"
      def deposit; end

      desc "withdraw TOKEN", "withdraw NFT"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def withdraw(token)
        payment =
          api.mixin_bot.create_multisig_transaction(
            keystore[:pin],
            asset_id: EXCHANGE_ASSET_ID,
            amount: MINIMUM_AMOUNT,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold],
            memo: TridentAssistant::Utils::Memo.new(type: "W", token_id: token).encode,
            trace_id: SecureRandom.uuid
          )

        log UI.fmt("{{v}} payment: #{payment}")
      end

      desc "airdrop TOKEN", "airdrop NFT"
      option :receiver, type: :string, aliases: "r", required: false, desc: "receiver ID of airdrop"
      option :start, type: :string, aliases: "s", required: false, desc: "start time of airdrop"
      option :expire, type: :string, aliases: "e", required: false, desc: "expire time of airdrop"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def airdrop(token)
        collectible = api.mixin_bot.collectibles["data"].find(&lambda { |c|
                                                                 c["token_id"] == token && c["state"] != "spent"
                                                               })
        raise "Cannot find NFT in wallet" if collectible.blank?

        log UI.fmt("{{v}} found collectible #{token}")

        memo = TridentAssistant::Utils::Memo.new(type: "AD", receiver_id: options[:receiver],
                                                 start_at: options[:start]).encode
        nfo = MixinBot::Utils::Nfo.new extra: memo.unpack1("H*")

        tx =
          if collectible["state"] == "signed"
            collectible["signed_tx"]
          else
            raw = api.mixin_bot.build_collectible_transaction(
              collectible: collectible,
              receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
              receivers_threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold],
              nfo: nfo.encode.hex
            )
            api.mixin_bot.sign_raw_transaction raw
          end

        request = api.mixin_bot.create_sign_collectible_request tx
        sign = api.mixin_bot.sign_collectible_request request["request_id"], keystore[:pin]
        result = api.mixin_bot.send_raw_transaction sign["raw_transaction"]

        log UI.fmt("{{v}} successfully transfer NFT")
        log result
      rescue StandardError => e
        log UI.fmt("{{x}} failed: #{e.inspect} #{e.backtrace.join("\n")}")
      end
    end
  end
end
