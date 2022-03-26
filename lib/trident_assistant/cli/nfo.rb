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

        Dir.glob("#{dir}/*.json").each do |file|
          _mint file
        rescue TridentAssistant::Utils::Metadata::InvalidFormatError, JSON::ParserError, Client::RequestError,
               MixinBot::Error, RuntimeError => e
          log UI.fmt("{{x}} #{file} failed: #{e.inspect}")
          next
        end
      end

      private

      def _mint(raw)
        # parse metadata
        data = TridentAssistant::Utils.parse_json raw
        metadata = TridentAssistant::Utils.parse_metadata data
        log UI.fmt("{{v}} metadata parsed")

        if data.dig("_mint", "token_id").present?
          log UI.fmt("{{v}} already minted: #{data["_mint"]["token_id"]}")
          return
        end

        # validate metadata
        metadata.validate!
        log UI.fmt("{{v}} metadata validated")

        raise "Creator ID incompatible with keystore" if metadata.creator[:id] != api.mixin_bot.client_id

        # upload metadata
        api.upload_metadata metadata: metadata.json, metahash: metadata.metahash
        log UI.fmt("{{v}} metadata uploaded: #{options[:endpoint]}/api/collectibles/#{metadata.metahash}")
        data["_mint"] ||= {}
        data["_mint"]["metahash"] = metadata.metahash

        # pay to NFO
        trace_id = SecureRandom.uuid
        memo = api.mixin_bot.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash
        payment =
          api.mixin_bot.create_multisig_transaction(
            keystore[:pin],
            {
              asset_id: TridentAssistant::Utils::MINT_ASSET_ID,
              trace_id: trace_id,
              amount: TridentAssistant::Utils::MINT_AMOUNT,
              memo: memo,
              receivers: TridentAssistant::Utils::NFO_MTG[:members],
              threshold: TridentAssistant::Utils::NFO_MTG[:threshold]
            }
          )

        log UI.fmt("{{v}} NFT mint payment paid: #{payment["data"]}") if payment["errors"].blank?
        data["_mint"]["trace_id"] = trace_id

        5.times do
          log UI.fmt("checking NFT in wallet...")
          collectible =
            api
            .mixin_bot
            .collectibles["data"]
            .find do |c|
              c["extra"] == metadata.metahash
            end
          if collectible.present?
            data["_mint"]["token_id"] = collectible["token_id"]
            log UI.fmt("{{v}} NFT found: #{collectible}")
            break
          end
          sleep 1
        rescue MixinBot::Error => e
          log UI.fmt("{{x}} #{e.inspect}")
          next
        end

        if File.file? raw
          File.write raw, data.to_json
        else
          log data
        end
        log UI.fmt("{{v}} NFT successfully minted")
      end
    end
  end
end
