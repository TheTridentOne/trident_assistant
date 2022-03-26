# frozen_string_literal: true

module TridentAssistant
  class API
    # api for order
    module Order
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      def orders(**kwargs)
        client.get(
          "api/orders",
          headers: {
            Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
          },
          params: {
            collection_id: kwargs[:collection_id],
            metahash: kwargs[:metahash],
            state: kwargs[:state],
            type: kwargs[:type]
          }
        )
      end

      def order(id)
        client
          .get(
            "api/orders/#{id}",
            headers: {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
            }
          )
      end

      def fill_order(order_id)
        _order = order order_id
        raise "Order state: #{_order["state"]}" if _order["state"] != "open"

        memo = TridentAssistant::Utils::Memo.new(type: "F", order_id: order_id, token_id: _order["token_id"])

        trace_id = SecureRandom.uuid
        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: _order["asset_id"],
            trace_id: trace_id,
            amount: _order["price"],
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end

      def cancel_order(order_id)
        _order = order order_id
        raise "Order maker: #{_order["maker"]["id"]}" if _order.dig("maker", "id") != mixin_bot.client_id
        raise "Order state: #{_order["state"]}" if _order["state"] != "open"

        memo = TridentAssistant::Utils::Memo.new(type: "C", order_id: order_id, token_id: _order["token_id"])

        trace_id = SecureRandom.uuid
        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: _order["asset_id"],
            trace_id: trace_id,
            amount: _order["price"],
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end
    end
  end
end
