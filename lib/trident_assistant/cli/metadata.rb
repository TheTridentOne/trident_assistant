# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI to generate metadata
    class Metadata < Base
      class InvalidError < TridentAssistant::Error; end

      desc "new", "generate a new metadata"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def new
        creator_id = api.mixin_bot.client_id
        creator_name = api.mixin_bot.me["full_name"]
        creator_royalty = UI.ask("Please input creator royalty, 0.0 ~ 0.1", default: "0.0")
        raise InvalidError, "Royalty must in 0.0 ~ 0.1" unless (0..0.1).include?(creator_royalty.to_f)

        collection_id = UI.ask("Please input collection ID")
        collection = api.collection collection_id
        raise InvalidError, "Cannot find collection #{collection_id}" if collection.blank?

        if collection["creator"]&.[]("id") != api.mixin_bot.client_id
          raise InvalidError,
                "Unauthorized to mint in #{collection_id}"
        end

        token_id = UI.ask("Please input token ID", default: "1")
        token_name = UI.ask("Please input token name")
        token_description = UI.ask("Please input token description")

        token_icon_url = UI.ask("Please input token icon url or local file dir")
        if File.file? token_icon_url
          begin
            file = File.open token_icon_url
            res = api.mixin_bot.upload_attachment file
            token_icon_url = res["view_url"]
          ensure
            file&.close
          end
        end

        token_media_url = UI.ask("Please input token media url or local file dir")
        if File.file? token_media_url
          begin
            file = File.open token_media_url
            res = api.mixin_bot.upload_attachment file
            token_media_url = res["view_url"]
            token_media_hash = SHA3::Digest::SHA256.hexdigest file.read
          ensure
            file&.close
          end
        elsif token_media_url =~ URI::DEFAULT_PARSER.make_regexp
          token_media_hash = TridentAssistant::Utils.hash_from_url(token_media_url)
        end

        metadata = TridentAssistant::Utils::Metadata.new(
          creator: {
            id: creator_id,
            name: creator_name,
            royalty: creator_royalty
          },
          collection: {
            id: collection_id,
            name: collection["name"],
            description: collection["description"],
            icon: {
              url: collection["icon"]&.[]("url")
            },
            split: collection["split"].to_s
          },
          token: {
            id: token_id,
            name: token_name,
            description: token_description,
            icon: {
              url: token_icon_url
            },
            media: {
              url: token_media_url,
              hash: token_media_hash.to_s
            }
          },
          checksum: {
            fields: ["creator.id", "creator.royalty", "collection.id", "collection.name",
                     "collection.split", "token.id", "token.name", "token.media.hash"],
            algorithm: "sha256"
          }
        )

        File.write "#{token_id}_#{collection_id}.json", metadata.json.to_json
        log metadata.json
      end

      desc "show METAHASH", "query metadata via metahash"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def show(metahash)
        log api.metadata metahash
      end

      desc "upload", "upload metadata to Trident"
      option :metadata, type: :string, aliases: "m", required: true, desc: "metadata or metadata.json file"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def upload
        metadata = TridentAssistant::Utils.parse_metadata options[:metadata]
        log UI.fmt("{{v}} metadata parsed")

        metadata.validate!
        log UI.fmt("{{v}} metadata validated")

        # upload metadata
        api.upload_metadata metadata: metadata.json, metahash: metadata.metahash
        log UI.fmt("{{v}} metadata uploaded: #{options[:endpoint]}/api/collectibles/#{metadata.metahash}")
      rescue JSON::ParserError, Client::RequestError, InvalidError => e
        log UI.fmt("{{x}} #{e.inspect}")
      end
    end
  end
end
