# frozen_string_literal: true

module TridentAssistant
  module Utils
    # build metadata of NFT
    class Memo
      attr_accessor :type, :token_id, :asset_id, :order_id, :price, :reserve_price, :receiver_id, :start_at,
                    :expire_at, :encoded, :decoded

      def initialize(**kwargs)
        @type = kwargs[:type]
        @token_id = kwargs[:token_id]
        @asset_id = kwargs[:asset_id]
        @order_id = kwargs[:order_id]
        @price = kwargs[:price]
        @reserve_price = kwargs[:reserve_price]
        @receiver_id = kwargs[:receiver_id]
        @start_at = kwargs[:start_at]
        @expire_at = kwargs[:expire_at]
        @encoded = kwargs[:encoded]
      end

      def json
        {
          T: type,
          N: token_id,
          A: asset_id,
          O: order_id,
          P: price,
          R: reserve_price,
          RC: receiver_id,
          S: start_at,
          E: expire_at
        }.compact
      end

      def encode
        hash = {
          T: type,
          N: token_id && MixinBot::Utils::UUID.new(hex: token_id).packed,
          A: asset_id && MixinBot::Utils::UUID.new(hex: asset_id).packed,
          O: order_id && MixinBot::Utils::UUID.new(hex: order_id).packed,
          P: price && format("%.8f", price.to_f).gsub(/(0)+\z/, ""),
          R: reserve_price && format("%.8f", reserve_price.to_f).gsub(/(0)+\z/, ""),
          RC: receiver_id && MixinBot::Utils::UUID.new(hex: receiver_id).packed,
          S: start_at && Time.parse(start_at).to_i,
          E: expire_at && Time.parse(expire_at).to_i
        }.compact

        @encoded =
          Base64.urlsafe_encode64(
            MessagePack.pack(hash),
            padding: false
          )
      end

      def decode
        json
      end
    end
  end
end
