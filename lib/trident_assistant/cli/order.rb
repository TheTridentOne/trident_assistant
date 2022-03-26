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

      desc "fill ID", "fill order"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def fill(id)
        log api.fill_order id
      end

      desc "cancel ID", "cancel order"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def cancel(id)
        log api.cancel_order id
      end

      desc "deposit TOKEN", "deposit NFT"
      def deposit(token)
        log api.deposit_nft token
      end

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
    end
  end
end
