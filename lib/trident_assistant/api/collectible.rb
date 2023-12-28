# frozen_string_literal: true

module TridentAssistant
  class API
    # api for collectible
    module Collectible
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      def collectibles(**kwargs)
        client
          .get(
            "api/collectibles",
            headers: {
              Authorization: "Bearer #{mixin_bot.access_token("GET", "/me")['access_token']}"
            },
            params: {
              collection_id: kwargs[:collection_id],
              type: kwargs[:type],
              page: kwargs[:page],
              query: kwargs[:query]
            }
          )
      end

      def deposit(collection, token)
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        collectible = find_collectible(:unspent, token_id)
        collectible ||= find_collectible(:signed, token_id)
        raise ForbiddenError, "Cannot find collectible" if collectible.blank?

        nfo = MixinBot::Utils::Nfo.new(extra: "deposit".unpack1("H*")).encode.hex
        _transfer_nft(
          collectible,
          nfo,
          receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
          threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
        )
      end

      def withdraw(collection, token)
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        mixin_bot.create_multisig_transaction(
          keystore[:pin],
          asset_id: EXCHANGE_ASSET_ID,
          amount: MINIMUM_AMOUNT,
          receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
          threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold],
          memo: TridentAssistant::Utils::Memo.new(type: "W", token_id: token_id).encode,
          trace_id: SecureRandom.uuid
        )
      end

      def airdrop(collection, token, **kwargs)
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        collectible = find_collectible(:unspent, token_id)
        collectible ||= find_collectible(:signed, token_id)
        raise ForbiddenError, "Cannot find collectible in wallet" if collectible.blank?

        memo =
          TridentAssistant::Utils::Memo.new(
            type: "AD",
            receiver_id: kwargs[:receiver_id],
            start_at: kwargs[:start_at]
          ).encode
        nfo = MixinBot::Utils::Nfo.new(extra: memo.unpack1("H*")).encode.hex

        _transfer_nft(
          collectible,
          nfo,
          receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
          threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
        )
      end

      def transfer(collection, token, recipient, **kwargs)
        token_id = MixinBot::Utils::Nfo.new(collection: collection, token: token).unique_token_id
        collectible = find_collectible(:unspent, token_id)
        collectible ||= find_collectible(:signed, token_id)
        raise ForbiddenError, "Cannot find collectible in wallet" if collectible.blank?

        memo = kwargs[:memo] || "TRANSFER"
        nfo = MixinBot::Utils::Nfo.new(extra: memo.unpack1("H*")).encode.hex

        _transfer_nft(
          collectible,
          nfo,
          receivers: [recipient],
          threshold: 1
        )
      end

      private

      def find_collectible(state, token_id)
        limit = 500
        offset = ""

        loop do
          r = mixin_bot.collectibles(state: state, limit: limit, offset: offset)["data"]
          puts "offset: #{offset}, loaded #{r.size} collectibles"
          collectible = r.find(&->(c) { c["token_id"] == token_id })
          break collectible if collectible.present?

          break if r.size < 500

          offset = r.last["updated_at"]
        end
      end

      def _transfer_nft(collectible, nfo, **kwargs)
        if collectible["state"] == "signed"
          mixin_bot.send_raw_transaction collectible["signed_tx"]
        else
          raw = mixin_bot.build_collectible_transaction(
            collectible: collectible,
            receivers: kwargs[:receivers],
            receivers_threshold: kwargs[:threshold],
            nfo: nfo
          )
          tx = mixin_bot.sign_raw_transaction raw

          request = mixin_bot.create_sign_collectible_request tx
          sign = mixin_bot.sign_collectible_request request["request_id"], keystore[:spend_key] || keystore[:pin]
          mixin_bot.send_raw_transaction sign["raw_transaction"]
        end
      end
    end
  end
end
