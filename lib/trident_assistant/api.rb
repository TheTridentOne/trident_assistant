# frozen_string_literal: true

module TridentAssistant
  # APIs of Trident server
  class API
    def collectible(metahash)
      client.get "/api/collectibles/#{metahash}"
    end
  end
end
