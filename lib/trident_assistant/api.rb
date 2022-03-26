# frozen_string_literal: true

require_relative "./client"
require_relative "./api/collection"
require_relative "./api/collectible"
require_relative "./api/metadata"
require_relative "./api/order"

module TridentAssistant
  # APIs of Trident server
  class API
    attr_reader :mixin_bot, :client, :keystore

    def initialize(**args)
      @client = Client.new endpoint: args[:endpoint]
      return if args[:keystore].blank?

      @keystore = TridentAssistant::Utils.parse_json args[:keystore]
      @mixin_bot = TridentAssistant::Utils.mixin_bot_from_keystore args[:keystore]
    end

    include TridentAssistant::API::Collectible
    include TridentAssistant::API::Collection
    include TridentAssistant::API::Metadata
    include TridentAssistant::API::Order
  end
end
