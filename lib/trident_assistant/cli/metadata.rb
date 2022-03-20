# frozen_string_literal: true

module TridentAssistant
  # CLI to generate metadata
  class CLI < Thor
    desc "new", "generate a new metadta"
    def new
      creator_id = UI.ask("Please input creator ID")
      creator_name = UI.ask("Please input creator Name")
      creator_royalty = UI.ask("Please input creator royalty", default: "0.0")

      collection_id = UI.ask("Please input collection ID", default: SecureRandom.uuid)
      collection_name = UI.ask("Please input collection name")
      collection_description = UI.ask("Please input collection description")
      collection_icon_url = UI.ask("Please input collection icon url")
      collection_split = UI.ask("Please input collection split", default: "0.0")

      token_id = UI.ask("Please input token ID", default: 1)
      token_name = UI.ask("Please input token name")
      token_description = UI.ask("Please input token description")
      token_icon_url = UI.ask("Please input token icon url")
      token_media_url = UI.ask("Please input token media url")
      token_media_hash = Utils.hash_from_url(token_media_url) if token_media_url.present?

      metadata = Utils::Metadata.new(
        creator: {
          id: creator_id,
          name: creator_name,
          royalty: creator_royalty
        },
        collection: {
          id: collection_id,
          name: collection_name,
          description: collection_description,
          icon: {
            url: collection_icon_url
          },
          split: collection_split
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
          fields: ["creator.id", "creator.royalty", "collection.id", "collection.name", "collection.split", "token.id",
                   "token.name", "token.media.hash"],
          algorithm: "sha256"
        }
      )

      File.write "#{token_id}_#{collection_id}.json", metadata.json.to_json
      log metadata.json
    end
  end
end
