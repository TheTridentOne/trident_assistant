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
          headers: {
            Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
          },
          params: {
            page: kwargs[:page]
          }
        )
      end

      def create_collection(**kwargs)
        kwargs = kwargs.with_indifferent_access
        client
          .post(
            "api/collections",
            headers: {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
            },
            json: {
              name: kwargs[:name],
              description: kwargs[:description],
              external_url: kwargs[:external_url],
              split: kwargs[:split].to_f.round(2),
              icon_base64: kwargs[:icon_base64],
              icon_url: kwargs[:icon_url]
            }
          )
      end

      def update_collection(id, **kwargs)
        kwargs = kwargs.with_indifferent_access
        client
          .put(
            "api/collections/#{id}",
            headers: {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
            },
            json: {
              description: kwargs[:description],
              external_url: kwargs[:external_url],
              icon_base64: kwargs[:icon_base64],
              icon_url: kwargs[:icon_url]
            }.compact
          )
      end
    end
  end
end
