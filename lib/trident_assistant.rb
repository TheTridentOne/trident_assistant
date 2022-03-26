# frozen_string_literal: true

require "mixin_bot"
require "open-uri"

# Trident SDK
module TridentAssistant
  class Error < StandardError; end

  def self.api
    TridentAssistant::API.new
  end
end

require_relative "trident_assistant/api"
require_relative "trident_assistant/cli"
require_relative "trident_assistant/utils"
require_relative "trident_assistant/version"
