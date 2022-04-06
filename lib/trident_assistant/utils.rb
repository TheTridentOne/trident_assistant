# frozen_string_literal: true

require_relative "./utils/memo"
require_relative "./utils/metadata"

module TridentAssistant
  # Some useful methods
  module Utils
    MINT_ASSET_ID = "c94ac88f-4671-3976-b60a-09064f1811e8"
    MINT_AMOUNT = 0.001
    NFO_MTG = {
      members: %w[
        047061e6-496d-4c35-b06b-b0424a8a400d
        4b188942-9fb0-4b99-b4be-e741a06d1ebf
        50115496-7247-4e2c-857b-ec8680756bee
        a51006d0-146b-4b32-a2ce-7defbf0d7735
        acf65344-c778-41ee-bacb-eb546bacfb9f
        cf4abd9c-2cfa-4b5a-b1bd-e2b61a83fabd
        dd655520-c919-4349-822f-af92fabdbdf4
      ].sort,
      threshold: 5
    }.freeze
    TRIDENT_MTG = {
      members: %w[
        6f5a84ce-d663-451e-b413-2d0c84b7629d
        99216bb5-9787-49b6-b251-537362ce23eb
        fcc1e3ec-97f1-41a7-89a3-20a0ec30a31f
        1a361145-66a7-48cd-ab6c-db9a42da4074
        9ba50819-159c-45e6-9bed-1eb2dded3360
      ].sort,
      threshold: 3
    }.freeze

    class << self
      def hash_from_url(url)
        return if url.to_s.blank?

        content =
          begin
            URI.parse(url).open(&:read)
          rescue OpenURI::HTTPError
            ""
          end

        SHA3::Digest::SHA256.hexdigest content
      end

      def mixin_bot_from_keystore(keystore)
        keystore = parse_json keystore if keystore.is_a?(String)

        MixinBot::API.new(
          client_id: keystore["client_id"],
          session_id: keystore["session_id"],
          pin_token: keystore["pin_token"],
          private_key: keystore["private_key"]
        )
      end

      def parse_metadata(input)
        metadata =
          case input
          when String
            TridentAssistant::Utils.parse_json input
          when Hash
            input
          else
            {}
          end
        TridentAssistant::Utils::Metadata.new(
          creator: metadata["creator"],
          collection: metadata["collection"],
          token: metadata["token"],
          checksum: metadata["checksum"]
        )
      end

      def parse_json(input)
        input =
          if File.file? input
            File.read input
          else
            input
          end
        JSON.parse(input).with_indifferent_access
      end
    end
  end
end
