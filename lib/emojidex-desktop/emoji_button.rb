require 'gtk3'
require_relative 'emoji_manager.rb'

module EmojidexDesktop
  # emoji buttons
  class EmojiButton < Gtk::Button
    @@unloaded_images = []    # [EmojiButton]

    def self.start_loadimage
      Thread.new do
        while btn = @@unloaded_images.shift
          btn.add_image EMOJI_MANAGER.get_picture(btn.emoji.code)
        end
      end
    end

    # public attrs
    attr_reader :emoji        # Emojidex::Emoji

    def validity
      return self.sensitive
    end

    def validity=(value)
      return self.sensitive(value)
    end

    def initialize(emoji)     # Emojidex::Emoji
      super()

      @emoji = emoji
      self.name = emoji.code
      @image = Gtk::Image.new
      add @image

      # clicked event
      signal_connect 'clicked' do |btn|
        Events.on_emoji_clicked btn    # see 'emojidex-editor.rb'
      end

      @@unloaded_images << self
    end

    def add_image(pict)
      @image.pixbuf = pict
    end
  end
end
