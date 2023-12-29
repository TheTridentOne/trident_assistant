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
            {
              metadata: metadata,
              metahash: metahash
            },
            {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me", "")}"
            }
          )
      end
    end
  end
end
