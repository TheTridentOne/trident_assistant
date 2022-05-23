# frozen_string_literal: true

module TridentAssistant
  class API
    # api for supported assets
    module MixinAsset
      def assets
        client.get "api/assets"
      end
    end
  end
end
