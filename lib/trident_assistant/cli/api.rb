# frozen_string_literal: true

module TridentAssistant
  # CLI to query Trident and Mixin APIs
  class CLI < Thor
    desc "metadata METAHASH", "query NFT metadata by metahash"
    def metadata(metahash)
      r = client.get "/api/collectibles/#{metahash}"
      log r
    end

    desc "orders", "query open orders"
    def orders; end

    desc "collectibles", "query collectibles in wallet"
    option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
    def collectibles
      r = bot.collectibles state: :unspent

      log r["data"]
    end

    desc "collectible UUID", "query collectible"
    option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
    def collectible(uuid)
      r = bot.collectible uuid

      log r["data"]
    end
  end
end
