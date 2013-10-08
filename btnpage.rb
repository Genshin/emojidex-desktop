#
# btnpage.rb
#
#     class MainWindow::EmojiButtonsPage
#
require 'gtk3'
require './emojibtn.rb'    # class EmojiButton
require './emojiman.rb'    # constant EMOJIS

#
# Notebook's tab page for "EmojiButton"s.
#
class MainWindow
	class EmojiButtonsPage < Gtk::ScrolledWindow
		def initialize(category_name)
			super()

			# shows a H-ScrollBar automatic, always shows a V-ScrollBar
			set_policy :automatic, :always

			# border width
			self.border_width = 1
			self.height_request = 200

			# select emojis in specified category
			emojis = (if category_name == 'all'
				EMOJIS
			else
				EMOJIS.select{|emoji| emoji['category'] == category_name }
			end)

			# Create a table for the page
			rows = emojis.size / 10 + 1
			table = Gtk::Table.new(rows, 10, true)

			# create emoji-buttons for the table
			x, y = 0, 0
			emojis.each {|emoji|
				btn = EmojiButton.new(emoji)
				table.attach(btn, x, x+1, y, y+1, :shrink, :shrink, 0, 0)
				x += 1
				next if x < 10
				y += 1
				x = 0
			}

			# add a table to the page
			add_with_viewport table
		end
	end
end
