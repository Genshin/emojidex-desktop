#
# mainwnd.rb
#
require 'gtk3'
require './btnpage.rb'    # class EmojiButtonsPage

#
# This class reads .glade, makes window from it, and shows it.
#
class MainWindow
	attr_reader :builder

	# show window
	def show
		@builder['main_window'].show_all
	end

	# initializer
	def initialize
		# load .glade file
		@builder = Gtk::Builder.new
		@builder.add_from_file 'mainwnd.glade'

		# quit events
		@builder['main_window'].signal_connect 'delete_event' do
			Gtk::main_quit
		end
		@builder['main_window'].signal_connect 'destroy' do
			Gtk::main_quit
		end

		# call Events (see 'poe.rb')
		@builder['btn_emojify'].signal_connect 'clicked' do
			Events.on_emojify_clicked
		end
		@builder['btn_de_emojify'].signal_connect 'clicked' do
			Events.on_de_emojify_clicked
		end
		@builder['btn_clip'].signal_connect 'clicked' do
			Events.on_clip_clicked
		end
		@builder['chk_stdonly'].signal_connect 'toggled' do |chk|
			Events.on_stdonly_toggled chk
		end

		# create tab-notebooks
		CATEGORY_NAMES.each do |category_name|
			# append (page, label) to tab
			page = EmojiButtonsPage.new(category_name)      # btnpage.rb
			label = Gtk::Label.new(" #{category_name} ")
			@builder['tab_notebook'].append_page page, label
		end
	end
end
