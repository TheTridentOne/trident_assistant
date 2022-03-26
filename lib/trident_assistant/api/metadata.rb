# frozen_string_literal: true

module TridentAssistant
  class API
    # api for metadata
    module Metadata
      def metadata(metahash)
        client.get "api/collectibles/#{metahash}"
      end

      def upload_metadata(metadata:, metahash:)
        client
          .post(
            "api/collectibles",
            headers: {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")}"
            },
            json: {
              metadata: metadata,
              metahash: metahash
            }
          )
      end
    end
  end
end
