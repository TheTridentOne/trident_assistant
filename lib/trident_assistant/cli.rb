# frozen_string_literal: true

require_relative "./client"

module TridentAssistant
  # CLI tool
  class CLI < Thor
    # https://github.com/Shopify/cli-ui
    UI = ::CLI::UI

    class_option :endpoint, type: :string, aliases: "-e", default: "thetrident.one", desc: "Specify trident endpoint"
    class_option :pretty, type: :boolean, aliases: "-r", default: true, desc: "Print output in pretty"

    attr_reader :keystore, :bot, :client

    def initialize(*args)
      super
      @client = Client.new host: options[:endpoint]

      return if options[:keystore].blank?

      @bot =
        begin
          @keystore = Utils.parse_json options[:keystore]
          Utils.mixin_bot_from_keystore @keystore
        rescue JSON::ParserError
          log UI.fmt("{{x}} falied to parse keystore.json: #{options[:keystore]}")
        rescue StandardError => e
          log UI.fmt "{{x}} Failed to initialize Mixin bot, maybe your keystore is incorrect. #{e.inspect}"
        end
    end

    desc "version", "Display TridentAssistant version"
    def version
      log VERSION
    end

    desc "mint", "Mint NFT from NFO"
    option :metadata, type: :string, aliases: "m", required: true, desc: "metadata or metadata.json file"
    option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
    def mint
      # parse metadata
      metadata = Utils.parse_metadata options[:metadata]
      log UI.fmt("{{v}} metadata parsed")

      # validate metadata
      if metadata.valid?
        log UI.fmt("{{v}} metadta validated, metahash: #{metadata.json}")
      else
        log UI.fmt("{{x}} metadata is invalid")
        log metadata.json
        return
      end

      # upload metadata
      upload =
        client
        .post(
          "api/collectibles",
          headers: {
            Authorization: "Bearer #{bot.access_token("GET", "/me")}"
          },
          json: {
            metadata: metadata.json,
            metahash: metadata.metahash
          }
        )
      log upload
      log UI.fmt("{{v}} metadata uploaded: https://#{options[:endpoint]}/api/collectibles/#{metadata.metahash}")

      # pay to NFO
      trace_id = SecureRandom.uuid
      memo = bot.api.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash
      if metadata.creator[:id] == bot.api.client_id
        payment =
          bot.api.create_multisig_transaction(
            keystore[:pin],
            {
              asset_id: Utils::MINT_ASSET_ID,
              trace_id: trace_id,
              amount: Utils::MINT_AMOUNT,
              memo: memo,
              receivers: Utils::NFO_MTG[:members],
              threshold: Utils::NFO_MTG[:threshod]
            }
          )

        log payment["data"]
        log UI.fmt("{{v}} NFT mint payment paid") if payment["errors"].blank?
      else
        payment =
          bot.api.create_multisig_payment(
            asset_id: Utils::MINT_ASSET_ID,
            trace_id: trace_id,
            amount: Utils::MINT_AMOUNT,
            memo: memo,
            receivers: Utils::NFO_MTG[:members],
            threshold: Utils::NFO_MTG[:threshod]
          )
        log payment["data"]
        log "Open the payment in Mixin Messenger: mixin://codes/#{payment["code_id"]}" if payment["code_id"].present?
      end
    rescue JSON::ParserError, Client::RequestError, MixinBot::Error => e
      log UI.fmt("{{x}} #{e.inspect}")
    end

    desc "hash", "Hash a string or file using sha256"
    option :string, type: :string, aliases: "s", desc: "String to hash"
    option :file, type: :string, aliases: "f", desc: "File to hash"
    def hash
      content =
        if options[:file].present? && File.file?(options[:file])
          File.read options[:file]
        elsif options[:string]
          options[:string]
        else
          log UI.fmt "{{x}}: either STRING or FILE is needed"
        end

      return if content.blank?

      log SHA3::Digest::SHA256.hexdigest(content)
    end

    desc "nft METAHASH", "query NFT by metahash"
    def nft(metahash)
      r = client.get "/api/collectibles/#{metahash}"
      log r
    end

    desc "orders", "query open orders"
    def orders; end

    def self.exit_on_failure?
      true
    end

    private

    def log(obj)
      if options[:pretty]
        if obj.is_a? String
          puts obj
        else
          ap obj
        end
      else
        puts obj.inspect
      end
    end
  end
end
