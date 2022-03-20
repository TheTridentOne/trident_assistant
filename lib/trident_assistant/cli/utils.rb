# frozen_string_literal: true

module TridentAssistant
  # CLI for utils
  class CLI < Thor
    desc "hash INPUT", "Hash a string or file using sha256"
    option :file, type: :boolean, aliases: "f", default: false, desc: "Hash a file"
    def hash(_input)
      content =
        if options[:file]
          File.read options[:input]
        else
          options[:input].to_s
        end

      log SHA3::Digest::SHA256.hexdigest(content)
    end
  end
end
