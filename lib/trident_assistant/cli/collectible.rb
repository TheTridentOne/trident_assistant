# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to query Trident and Mixin APIs
    class Collectible < Base
      desc "index", "query collectibles in wallet"
      option :state, type: :string, aliases: "s", required: false, default: :unspent,
                     desc: "keystore or keystore.json file of Mixin bot"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def index
        r = api.mixin_bot.collectibles state: options[:state]

        log r["data"]
      end

      desc "show UUID", "query collectible"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def show(uuid)
        r = api.mixin_bot.collectible uuid

        log r["data"]
      end
    end
  end
end
