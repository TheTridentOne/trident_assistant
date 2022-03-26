# frozen_string_literal: true

module TridentAssistant
  class API
    # api for order
    module Order
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
    end
  end
end
