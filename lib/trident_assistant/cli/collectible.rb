# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to query Trident and Mixin APIs
    class Collectible < Base
      desc "all", "query collectibles in wallet"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def all
        r = bot.collectibles state: :unspent

        log r["data"]
      end

      desc "query UUID", "query collectible"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def query(uuid)
        r = bot.collectible uuid

        log r["data"]
      end
    end
  end
end
