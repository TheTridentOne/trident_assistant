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
      option :page, type: :numeric, aliases: "p", required: false, desc: "page"
      def index
        log api.orders(
          collection_id: options[:collection],
          metahash: options[:metahash],
          state: options[:state],
          type: options[:type],
          page: options[:page]
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
    end
  end
end
