#
# emojidex-editor.rb
#
require './mainwnd.rb'     # class MainWindow
require './emojiman.rb'    # constant EMOJIS

# Create a main window, and publish for following codes
MAIN_WINDOW = MainWindow.new

#
# All events
#
module Events
	# Emojify button clicked
	EMOJIFY_RE = /^([^:]*)\:([^:]+)\:(.*)$/o    # RegExp to emojify
	def self.on_emojify_clicked
		# parse emoji-tags, and append to buffer (inner-procedure)
		parse_and_append = lambda {|src_str, txtbuf|
			s = src_str
			while EMOJIFY_RE =~ s
				txtbuf.insert txtbuf.end_iter, $1
				name, s = $2, $3
				emoji = EMOJIS.find{|emoji| emoji['name'] == name }
				txtbuf.insert txtbuf.end_iter, emoji['picture']
			end

			# emoji-tag is use-upped, so append rest
			txtbuf.insert txtbuf.end_iter, s
		}

		# temp-buffer, and result-buffer
		tmp, buf = '', Gtk::TextBuffer.new

		# read by each chars
		it = MAIN_WINDOW.builder['text'].buffer.start_iter
		begin
			if it.pixbuf    # it's a picture
				# parse temp-buffer and append to result-buffer
				parse_and_append.call tmp, buf

				# then, append a picture as is, and clear temp-buffer
				buf.insert buf.end_iter, it.pixbuf
				tmp = ''
			else
				# it's a char
				tmp += it.char    # append the char to temp-buffer
			end
		end while it.forward_char

		# parse rest temp-buffer and append to result-buffer
		parse_and_append.call tmp, buf

		# set result-buffer to text
		MAIN_WINDOW.builder['text'].buffer = buf
	end

	# deEmojify button clicked
	def self.on_de_emojify_clicked
		# result buffer
		buf = Gtk::TextBuffer.new

		# read by each chars
		it = MAIN_WINDOW.builder['text'].buffer.start_iter
		begin
			if it.pixbuf    # it's a picture
				# translate to emoji-tag, and append
				emoji = EMOJIS.find{|emoji|
					emoji['picture'] == it.pixbuf
				}
				buf.insert buf.end_iter, ":#{emoji['name']}:"
			else            # it's a char
				# append it as is
				buf.insert buf.end_iter, it.char
			end
		end while it.forward_char

		# replace buffer of text
		MAIN_WINDOW.builder['text'].buffer = buf
	end

	# clip button clicked
	def self.on_clip_clicked
		clpbrd = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)

		# get string from text, and set to clipboard
		clpbrd.text = MAIN_WINDOW.builder['text'].buffer.text

		# memo: Pixbuf to clip-board
		# clpbrd.image = obj if obj.class == Gdk::Pixbuf
	end

	# each emoji-buttons clicked
	def self.on_emoji_clicked(emoji_btn)
		# set object to text (inner procedure)
		set_text = lambda {|obj|
			if MAIN_WINDOW.builder['chk_append'].active?    # append mode
				# insert obj to cursor-position on the buffer of text
				buf = MAIN_WINDOW.builder['text'].buffer
				buf.insert buf.get_iter_at(:mark=>buf.selection_bound), obj
			else    # not append mode
				# set to new empty buffer
				buf = Gtk::TextBuffer.new
				buf.insert buf.end_iter, obj
				MAIN_WINDOW.builder['text'].buffer = buf
			end
		}

		# switch by radio button
		if MAIN_WINDOW.builder['radio_tag'].active?           # emoji-tag
			set_text.call ":#{emoji_btn.name}:"
		elsif MAIN_WINDOW.builder['radio_unicode'].active?    # unicode
			set_text.call emoji_btn.moji
		elsif MAIN_WINDOW.builder['radio_picture'].active?    # picture
			set_text.call emoji_btn.image.pixbuf
		end

		# return focus to text
		MAIN_WINDOW.builder['text'].focus = true
	end

	# standard emoji only check-toggled
	def self.on_stdonly_toggled(chk_stdonly)
		# change validities of each emoji-buttons
		MAIN_WINDOW.builder['tab_notebook'].children.each do |page|
			page.child.child.children.each do |emoji_btn|
				emoji_btn.validity = (
					emoji_btn.standard? || !chk_stdonly.active?)
			end
		end
	end
end

# start application
MAIN_WINDOW.show
Gtk::main
