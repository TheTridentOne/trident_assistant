# frozen_string_literal: true

module TridentAssistant
  module Utils
    # build metadata of NFT
    class Metadata
      class InvalidFormatError < TridentAssistant::Error; end

      attr_reader :creator, :collection, :token, :checksum

      def initialize(**kwargs)
        @creator = kwargs[:creator] || {}
        @collection = kwargs[:collection] || {}
        @token = kwargs[:token] || {}
        @checksum = kwargs[:checksum] || {}
      end

      def json
        {
          creator: creator,
          collection: collection,
          token: token,
          checksum: checksum
        }.compact.with_indifferent_access
      end

      def validate!
        raise InvalidFormatError, creator unless creator_valid?
        raise InvalidFormatError, collection unless collection_valid?
        raise InvalidFormatError, token unless token_valid?
        raise InvalidFormatError, checksum unless checksum_valid?
        raise InvalidFormatError, "failed to validate hash" unless all_hash_valid?

        true
      end

      def valid?
        creator_valid? && collection_valid? && token_valid? && checksum_valid? && all_hash_valid?
      end

      def creator_valid?
        return false unless creator.is_a?(Hash)

        @creator = creator.with_indifferent_access
        creator["id"].present? && creator["name"].present?
      end

      def collection_valid?
        return false unless collection.is_a?(Hash)

        @collection = collection.with_indifferent_access
        return false unless collection["id"].match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
        return false if collection["name"].blank?

        true
      end

      def token_valid?
        return false unless token.is_a?(Hash)

        @token = token.with_indifferent_access
        return false unless token["id"].match?(/\A(?!0)\d+\z/)
        return false if token["id"].to_i > 8**64
        return false if token["name"].blank?

        true
      end

      def checksum_valid?
        return false unless checksum.is_a?(Hash)

        @checksum = checksum.with_indifferent_access
        checksum["algorithm"] && checksum["fields"].is_a?(Array)
      end

      def all_hash_valid?
        checksum["fields"].each do |field|
          value = json

          field.split(".").each do |key|
            next unless value.is_a?(Hash)

            return false if key == "hash" && value["hash"] != TridentAssistant::Utils.hash_from_url(value["url"])

            value = value[key]
          end
        end

        true
      end

      def checksum_content
        return unless checksum_valid?

        checksum["fields"].map do |field|
          value = json
          field.split(".").each do |key|
            value = (value[key] if value.is_a?(Hash))
          end
          value.to_s
        end.join
      end

      def metahash
        return unless valid?

        alg = checksum["algorithm"]
        case alg
        when "sha256", "sha3-256"
          SHA3::Digest::SHA256.hexdigest checksum_content
        else
          raise "algorithm #{alg} not supported!"
        end
      end
    end
  end
end
