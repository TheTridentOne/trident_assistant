# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  # CLI tool of collection
  module CLI
    class Collection < Base
      desc "create", "create a new collection"
      def create; end

      desc "update", "update collection"
      def update; end

      desc "query ID", "query a collection"
      def query(id); end
    end
  end
end
