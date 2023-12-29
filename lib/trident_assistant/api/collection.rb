# frozen_string_literal: true

module TridentAssistant
  class API
    # api for collection
    module Collection
      def collection(id)
        client.get(
          "api/collections/#{id}"
        )
      end

      def collections(**kwargs)
        client.get(
          "api/collections",
          {
            page: kwargs[:page]
          },
          {
            Authorization: "Bearer #{mixin_bot.access_token("GET", "/me", "")}"
          }
        )
      end

      def create_collection(**kwargs)
        kwargs = kwargs.with_indifferent_access
        client
          .post(
            "api/collections",
            {
              name: kwargs[:name],
              symbol: kwargs[:symbol],
              description: kwargs[:description],
              external_url: kwargs[:external_url],
              split: kwargs[:split].to_f.round(4),
              icon_base64: kwargs[:icon_base64],
              icon_url: kwargs[:icon_url]
            },
            {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me", "")}"
            }
          )
      end

      def update_collection(id, **kwargs)
        kwargs = kwargs.with_indifferent_access
        client
          .put(
            "api/collections/#{id}",
            {
              description: kwargs[:description],
              external_url: kwargs[:external_url],
              icon_base64: kwargs[:icon_base64],
              icon_url: kwargs[:icon_url]
            }.compact,
            {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me", "")}"
            }
          )
      end
    end
  end
end
