#
# emojibtn.rb
#
#     class EmojiButton
#

require 'gtk3'

#
# each Emoji buttons
#
class EmojiButton < Gtk::Button
	# public attributes
	attr_reader :moji           # Unicode character (if not exists: nil)
	attr_reader :image          # Gtk::Image for each buttons
	attr_reader :emoji          # emoji data: Hash

	# validity (true / false)
	def validity
		self.sensitive
	end
	def validity=(value)
		self.sensitive = value
		# write some tasks on validity change...
	end

	# has a standard char?
	def standard?
		return @is_standard
	end

	# initializer
	def initialize(emoji)    # Hash (see 'emojiman.rb')
		super()

		@emoji = emoji

		# create each buttons' images by loaded pictures
		@image = Gtk::Image.new(:pixbuf => emoji['picture'])

		# set name and image of button
		self.name = emoji['name']
		add @image

		# is it standard char? (exist Unicode-char?)
		if emoji['moji']
			then @is_standard, @moji = true, emoji['moji']
			else @is_standard, @moji = false, 'unicode not exist'
		end

		# clicked event
		signal_connect 'clicked' do |btn|
			Events.on_emoji_clicked btn    # see 'poe.rb'
		end
	end
end
