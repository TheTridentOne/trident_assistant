# frozen_string_literal: true

module TridentAssistant
  # CLI to transfer to Trident MTG
  class CLI < Thor
    desc "sell TOKEN", "sell NFT at fixed price"
    def sell(token); end

    desc "auction TOKEN", "auction NFT"
    def auction(token); end

    desc "bid TOKEN", "bid NFT"
    def bid; end

    desc "accept ORDER", "accept order"
    def accept; end

    desc "cancel ORDER", "cancel order"
    def cancel; end

    desc "withdraw TOKEN", "withdraw NFT"
    def withdraw; end

    desc "deposit TOKEN ", "deposit NFT"
    def deposit; end

    desc "airdrop TOKEN", "airdrop NFT"
    option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
    option :receiver, type: :string, aliases: "r", required: false, desc: "receiver ID of airdrop"
    option :start, type: :string, aliases: "s", required: false, desc: "start time of airdrop"
    option :expire, type: :string, aliases: "e", required: false, desc: "expire time of airdrop"
    def airdrop(token)
      collectible = bot.collectibles["data"].find(&->(c) { c["token_id"] == token && c["state"] != "spent" })
      raise "Cannot find NFT in wallet" if collectible.blank?

      log UI.fmt("{{v}} find collectible")

      memo = Utils::Memo.new(type: "AD").encode
      nfo = MixinBot::Utils::Nfo.new extra: memo.unpack1("H*")

      tx =
        if collectible["state"] == "signed"
          collectible["signed_tx"]
        else
          raw = bot.build_collectible_transaction(
            collectible: collectible,
            receivers: Utils::TRIDENT_MTG[:members],
            receivers_threshold: Utils::TRIDENT_MTG[:threshod],
            nfo: nfo.encode.hex
          )
          bot.sign_raw_transaction raw
        end

      request = bot.create_sign_collectible_request tx
      sign = bot.sign_collectible_request request["request_id"], keystore[:pin]
      result = bot.send_raw_transaction sign["raw_transaction"]

      log UI.fmt("{{v}} successfully transfer NFT")
      log result
    rescue StandardError => e
      log UI.fmt("{{x}} failed: #{e.inspect}")
    end
  end
end
