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
        # parse metadata
        metadata = TridentAssistant::Utils.parse_metadata options[:metadata]
        log UI.fmt("{{v}} metadata parsed")

        if metadata._metadata.present?
          log UI.fmt("{{v}} already minted: #{metadata._metadata}")
          return
        end

        # validate metadata
        metadata.validate!
        log UI.fmt("{{v}} metadata validated")

        # upload metadata
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
        log UI.fmt("{{v}} metadata uploaded: #{options[:endpoint]}/api/collectibles/#{metadata.metahash}")

        # pay to NFO
        trace_id = SecureRandom.uuid
        memo = bot.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash
        if metadata.creator[:id] == bot.client_id
          payment =
            bot.create_multisig_transaction(
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
          File.write(
            options[:metadata],
            metadata.json.merge(
              _metadata: "#{options[:endpoint]}/api/collectibles/#{metadata.metahash}"
            ).to_json
          )
        else
          payment =
            bot.create_multisig_payment(
              asset_id: TridentAssistant::Utils::MINT_ASSET_ID,
              trace_id: trace_id,
              amount: TridentAssistant::Utils::MINT_AMOUNT,
              memo: memo,
              receivers: TridentAssistant::Utils::NFO_MTG[:members],
              threshold: TridentAssistant::Utils::NFO_MTG[:threshold]
            )
          log payment["data"]
          log "Open the payment in Mixin Messenger: mixin://codes/#{payment["code_id"]}" if payment["code_id"].present?
        end
      rescue JSON::ParserError, Client::RequestError, TridentAssistant::Utils::Metadata::InvalidFormatError,
             MixinBot::Error => e
        log UI.fmt("{{x}} #{e.inspect}")
      end

      desc "bulkmint DIR", "Mint NFT in bulk"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      option :out, type: :string, aliases: "o", required: false, desc: "directory of minted metadata json files"
      def bulkmint(dir)
        raise "#{dir} is not a directory" unless Dir.exist?(dir)

        Dir.glob("#{dir}/*.json").each do |file|
          json = File.read file
          metadata = TridentAssistant::Utils.parse_metadata json
          log UI.fmt("{{v}} #{file} metadata parsed")

          if metadata._metadata.present?
            log UI.fmt("{{v}} already minted: #{metadata._metadata}")
            next
          end

          metadata.validate!
          log UI.fmt("{{v}} #{file} metadata validated")

          # ingore minted metadata.json
          next if file.split("_").first == metadata.metahash

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
          log UI.fmt("{{v}} #{file} metadata uploaded: #{options[:endpoint]}/api/collectibles/#{metadata.metahash}")

          trace_id = SecureRandom.uuid
          memo = bot.nft_memo metadata.collection[:id], metadata.token[:id].to_i, metadata.metahash
          payment =
            bot.create_multisig_transaction(
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

          log UI.fmt("{{v}} #{file} NFT mint payment paid: #{payment["data"]}") if payment["errors"].blank?

          File
            .write(
              file,
              metadata.json.merge(
                _metadata: "#{options[:endpoint]}/api/collectibles/#{metadata.metahash}"
              ).to_json
            )
        rescue TridentAssistant::Utils::Metadata::InvalidFormatError, JSON::ParserError, Client::RequestError,
               MixinBot::Error => e
          log UI.fmt("{{x}} #{file} failed: #{e.inspect}")
          next
        end
      end
    end
  end
end
