# frozen_string_literal: true

module TridentAssistant
  class API
    # api for collectible
    module Collectible
      EXCHANGE_ASSET_ID = "965e5c6e-434c-3fa9-b780-c50f43cd955c"
      MINIMUM_AMOUNT = 0.000_000_01

      def deposit(token_id)
        collectible = mixin_bot.collectibles(state: :unspent)["data"].find(&->(c) { c["token_id"] == token_id })
        raise "Unauthorized" if collectible.blank?

        nfo = MixinBot::Utils::Nfo.new(extra: "deposit".unpack1("H*")).encode.hex
        _transfer_nft(
          collectible,
          nfo,
          receivers: TridentAssistant::Utils::TRIDENT_MTG[:members],
          threshold: TridentAssistant::Utils::TRIDENT_MTG[:threshold]
        )
      end

      def withdraw(token_id)
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

      def airdrop(token_id, **kwargs)
        collectible = mixin_bot.collectibles(state: :unspent)["data"].find(&->(c) { c["token_id"] == token_id })
        collectible ||= mixin_bot.collectibles(state: :signed)["data"].find(&->(c) { c["token_id"] == token_id })
        raise "Unauthorized" if collectible.blank?

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

      private

      def _transfer_nft(collectible, nfo, **kwargs)
        tx =
          if collectible["state"] == "signed"
            collectible["signed_tx"]
          else
            raw = mixin_bot.build_collectible_transaction(
              collectible: collectible,
              receivers: kwargs[:receivers],
              receivers_threshold: kwargs[:threshold],
              nfo: nfo
            )
            mixin_bot.sign_raw_transaction raw
          end

        request = mixin_bot.create_sign_collectible_request tx
        sign = mixin_bot.sign_collectible_request request["request_id"], keystore[:pin]
        mixin_bot.send_raw_transaction sign["raw_transaction"]
      end
    end
  end
end
