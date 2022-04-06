# frozen_string_literal: true

require_relative "./base"

module TridentAssistant
  module CLI
    # CLI tool of collection
    class Collection < Base
      class InvalidError < TridentAssistant::Error; end

      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      desc "index", "query all collections"
      def index
        log api.collections
      end

      option :name, type: :string, aliases: "n", desc: "collection Name"
      option :description, type: :string, aliases: "d", desc: "collection Description"
      option :icon, type: :string, aliases: "i", desc: "collection Icon"
      option :url, type: :string, aliases: "u", desc: "collection External URL"
      option :split, type: :string, aliases: "s", desc: "collection Split"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      desc "create", "create a new collection"
      def create
        name = options[:name] || UI.ask("Please input collection name")
        raise InvalidError, "Name cannot be blank" if name.blank?

        description = options[:description] || UI.ask("Please input collection description")
        raise InvalidError, "Description cannot be blank" if description.blank?

        icon = options[:icon] || UI.ask("Please input icon file or icon url")
        icon_file = File.open(icon) if File.exist? icon

        external_url = options[:url] || UI.ask("Please input collection external url, start with https:// or http://")
        split = options[:split] || UI.ask("Please input collection split", default: "0.0")
        payload = {
          name: name,
          description: description,
          external_url: external_url,
          split: split
        }

        if icon_file.present?
          payload[:icon_base64] = Base64.strict_encode64(icon_file.read)
        else
          payload[:icon_url] = icon
        end

        log api.create_collection(**payload)
      rescue InvalidError => e
        log UI.fmt("{{x}} failed: #{e.inspect}")
      ensure
        icon_file&.close
      end

      desc "update ID", "update collection"
      option :description, type: :string, aliases: "d", desc: "collection Description"
      option :icon, type: :string, aliases: "i", desc: "collection Icon"
      option :url, type: :string, aliases: "u", desc: "collection External URL"
      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      def update(id)
        payload = {}
        payload[:description] = options[:description] if options[:description].present?
        payload[:external_url] = options[:url] if options[:url].present?
        if options[:icon].present? && File.exist?(options[:icon])
          icon = File.open options[:icon]
          payload[:icon_base64] = Base64.strict_encode64(icon.read)
        end
        log api.update_collection(id, **payload)
      ensure
        icon&.close
      end

      option :keystore, type: :string, aliases: "k", required: true, desc: "keystore or keystore.json file of Mixin bot"
      desc "show ID", "query a collection"
      def show(id)
        log api.collection id
      end
    end
  end
end
