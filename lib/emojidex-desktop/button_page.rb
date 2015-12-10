require 'gtk3'
require_relative 'emoji_button'

module EmojidexDesktop
  # GTK Notebook tab page template to fill with emoji buttons.
  class EmojiButtonPage < Gtk::ScrolledWindow
    def initialize(category_name, emojis)   # String, [Emojidex::Emoji]
      super()

      # shows a H-ScrollBar automatic, always shows a V-ScrollBar
      set_policy :automatic, :always

      # border width
      self.border_width = 1
      self.height_request = 200

      # Create a table for the page
      rows = emojis.size / 10 + 1
      table = Gtk::Table.new(rows, 10, true)

      # create emoji-buttons for the table
      x, y = 0, 0
      emojis.each do |emoji|
        btn = EmojiButton.new(emoji)    # emojibtn.rb
        table.attach btn, x, x+1, y, y+1, :shrink, :shrink, 0, 0
        x += 1
        next if x < 10
        y += 1
        x = 0
      end

      # add a table to the page
      add_with_viewport table
    end
  end
end
