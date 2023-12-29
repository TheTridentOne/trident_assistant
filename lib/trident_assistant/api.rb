# frozen_string_literal: true

require_relative "./client"
require_relative "./api/collection"
require_relative "./api/collectible"
require_relative "./api/metadata"
require_relative "./api/mixin_asset"
require_relative "./api/order"

module TridentAssistant
  # APIs of Trident server
  class API
    class UnauthorizedError < TridentAssistant::Error; end
    class ArgumentError < TridentAssistant::Error; end
    class ForbiddenError < TridentAssistant::Error; end

    attr_reader :mixin_bot, :client, :keystore

    def initialize(**args)
      @client = Client.new endpoint: args[:endpoint], debug: args[:debug]
      return if args[:keystore].blank?

      @keystore = TridentAssistant::Utils.parse_json args[:keystore]
      @mixin_bot = TridentAssistant::Utils.mixin_bot_from_keystore args[:keystore]
    end

    include TridentAssistant::API::Collectible
    include TridentAssistant::API::Collection
    include TridentAssistant::API::Metadata
    include TridentAssistant::API::MixinAsset
    include TridentAssistant::API::Order
  end
end
