# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to mint NFTs
    class NFO < Base
      desc "mint", "Mint NFT from NFO"
      option :metadata, type: :string, aliases: "m", required: true, desc: "metadata or metadata.json file"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def mint
        _mint options[:metadata]
      rescue JSON::ParserError, Client::RequestError, TridentAssistant::Utils::Metadata::InvalidFormatError,
             MixinBot::Error, RuntimeError => e
        log UI.fmt("{{x}} #{e.inspect}")
      end

      desc "bulkmint DIR", "Mint NFT in bulk"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def bulkmint(dir)
        raise "#{dir} is not a directory" unless Dir.exist?(dir)

        files = Dir.glob("#{dir}/*.json")
        minted = []
        files.each do |file|
          log "-" * 80
          log UI.fmt("{{v}} found #{file}")
          minted.push(file) if _mint(file)
        rescue TridentAssistant::Utils::Metadata::InvalidFormatError, JSON::ParserError, Client::RequestError,
               MixinBot::Error, RuntimeError => e
          log UI.fmt("{{x}} #{file} failed: #{e.inspect}")
          next
        end
      ensure
        log UI.fmt("Found #{files.size} json file, minted #{minted.size}")
      end

      private

      def _mint(raw)
        # parse metadata
        data = TridentAssistant::Utils.parse_json raw
        metadata = TridentAssistant::Utils.parse_metadata data
        log UI.fmt("{{v}} metadata parsed")

        # validate metadata
        metadata.validate!
        log UI.fmt("{{v}} metadata validated")

        raise "Creator ID incompatible with keystore" if metadata.creator[:id] != api.mixin_bot.client_id

        # upload metadata
        if data.dig("_mint", "metahash").blank?
          api.upload_metadata metadata: metadata.json, metahash: metadata.metahash
          data["_mint"] ||= {}
          data["_mint"]["metahash"] = metadata.metahash
        end
        log UI.fmt("{{v}} metadata uploaded: #{options[:endpoint]}/api/collectibles/#{metadata.metahash}")

        token_id = MixinBot::Utils::Nfo.new(collection: metadata.collection[:id],
                                            token: metadata.token[:id]).unique_token_id
        collectible =
          begin
            api.mixin_bot.collectible token_id
          rescue MixinBot::NotFoundError
            nil
          end
        if collectible.present?
          log UI.fmt("{{v}} already minted: #{token_id}")
          return true
        end

        # pay to NFO
        trace_id = data.dig("_mint", "trace_id") || SecureRandom.uuid
        memo = api.mixin_bot.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash

        data["_mint"]["trace_id"] = trace_id
        loop do
          payment =
            begin
              api.mixin_bot.create_multisig_transaction(
                api.keystore[:pin],
                {
                  asset_id: TridentAssistant::Utils::MINT_ASSET_ID,
                  trace_id: trace_id,
                  amount: TridentAssistant::Utils::MINT_AMOUNT,
                  memo: memo,
                  receivers: TridentAssistant::Utils::NFO_MTG[:members],
                  threshold: TridentAssistant::Utils::NFO_MTG[:threshold]
                }
              )
            rescue MixinBot::InsufficientPoolError, MixinBot::HttpError => e
              log UI.fmt("{{x}} #{e.inspect}")
              log "Retrying to pay..."
              sleep 1
              nil
            end

          next if payment.blank? || payment["errors"].present?

          log UI.fmt("{{v}} NFT mint payment paid: #{payment["data"]}")
          data["_mint"]["token_id"] = token_id
          log UI.fmt("{{v}} NFT successfully minted")
          break
        end

        data.dig("_mint", "token_id").present?
      ensure
        if File.file? raw
          File.write raw, data.to_json
        else
          log data
        end
      end
    end
  end
end
