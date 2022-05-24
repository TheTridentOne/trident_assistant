# frozen_string_literal: true

module TridentAssistant
  class API
    # api for order
    module Order
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      def orders(**kwargs)
        authorization = mixin_bot ? mixin_bot.access_token("GET", "/me") : ""
        client.get(
          "api/orders",
          headers: {
            Authorization: "Bearer #{authorization}"
          },
          params: {
            collection_id: kwargs[:collection_id],
            metahash: kwargs[:metahash],
            state: kwargs[:state],
            type: kwargs[:type],
            maker_id: kwargs[:maker_id],
            page: kwargs[:page]
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

      def ask_order(collection, token, **kwargs)
        raise ArgumentError, "price cannot be blank" if kwargs[:price].blank?
        raise ArgumentError, "asset_id cannot be blank" if kwargs[:asset_id].blank?

        trace_id = SecureRandom.uuid
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        memo =
          TridentAssistant::Utils::Memo
          .new(
            type: "A",
            order_id: trace_id,
            token_id: token_id,
            price: kwargs[:price],
            asset_id: kwargs[:asset_id],
            expire_at: kwargs[:expire_at]
          )

        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: EXCHANGE_ASSET_ID,
            trace_id: trace_id,
            amount: MINIMUM_AMOUNT,
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end

      def auction_order(collection, token, **kwargs)
        raise ArgumentError, "price cannot be blank" if kwargs[:price].blank?
        raise ArgumentError, "asset_id cannot be blank" if kwargs[:asset_id].blank?

        trace_id = SecureRandom.uuid
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        memo =
          TridentAssistant::Utils::Memo
          .new(
            type: "AU",
            order_id: trace_id,
            token_id: token_id,
            price: kwargs[:price],
            reserve_price: kwargs[:reserve_price],
            asset_id: kwargs[:asset_id],
            expire_at: kwargs[:expire_at]
          )

        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: EXCHANGE_ASSET_ID,
            trace_id: trace_id,
            amount: MINIMUM_AMOUNT,
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end

      def bid_order(collection, token, **kwargs)
        raise ArgumentError, "price cannot be blank" if kwargs[:price].blank?
        raise ArgumentError, "asset_id cannot be blank" if kwargs[:asset_id].blank?

        trace_id = SecureRandom.uuid
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        memo =
          TridentAssistant::Utils::Memo
          .new(
            type: "B",
            order_id: trace_id,
            token_id: token_id,
            asset_id: kwargs[:asset_id],
            expire_at: kwargs[:expire_at]
          )

        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: kwargs[:asset_id],
            trace_id: trace_id,
            amount: kwargs[:price],
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end

      def fill_order(order_id)
        info = order order_id
        raise "Order state: #{info["state"]}" if info["state"] != "open"

        memo = TridentAssistant::Utils::Memo.new(type: "F", order_id: order_id, token_id: info["token_id"])

        trace_id = SecureRandom.uuid
        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: info["type"] == "BidOrder" ? EXCHANGE_ASSET_ID : info["asset_id"],
            trace_id: trace_id,
            amount: info["type"] == "BidOrder" ? MINIMUM_AMOUNT : info["price"],
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end

      def cancel_order(order_id)
        info = order order_id
        raise ForbiddenError, "Order maker: #{info["maker"]["id"]}" if info.dig("maker", "id") != mixin_bot.client_id
        raise ForbiddenError, "Order state: #{info["state"]}" if info["state"] != "open"

        memo = TridentAssistant::Utils::Memo.new(type: "C", order_id: order_id, token_id: info["token_id"])

        trace_id = SecureRandom.uuid
        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          {
            asset_id: EXCHANGE_ASSET_ID,
            trace_id: trace_id,
            amount: MINIMUM_AMOUNT,
            memo: memo.encode,
            receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
            threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
          }
        )
      end
    end
  end
end
