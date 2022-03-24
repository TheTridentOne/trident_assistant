# frozen_string_literal: true

require_relative "./cli/base"
require_relative "./cli/collectible"
require_relative "./cli/collection"
require_relative "./cli/metadata"
require_relative "./cli/nfo"
require_relative "./cli/order"
require_relative "./cli/utils"

module TridentAssistant
  # CLI tool
  module CLI
    # Main commands of CLI
    class Command < TridentAssistant::CLI::Base
      class_option :endpoint, type: :string, aliases: "-e", default: "https://thetrident.one",
                              desc: "Specify trident endpoint"
      class_option :pretty, type: :boolean, aliases: "-r", default: true, desc: "Print output in pretty"

      desc "version", "Display TridentAssistant version"
      def version
        log VERSION
      end

      def self.exit_on_failure?
        true
      end

      desc "collectible", "commands for collectible"
      subcommand "collectible", CLI::Collectible

      desc "collection", "commands for collection"
      subcommand "collection", CLI::Collection

      desc "nfo", "commands for nfo"
      subcommand "nfo", CLI::NFO

      desc "metadata", "commands for metadata"
      subcommand "metadata", CLI::Metadata

      desc "order", "commands for order"
      subcommand "order", CLI::Order
    end
  end
end
