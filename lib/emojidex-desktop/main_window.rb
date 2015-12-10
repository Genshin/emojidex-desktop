require 'gtk3'

require_relative 'button_page'

module EmojidexDesktop
  # Generates the main window from the glade file
  class MainWindow
    attr_reader :builder

    module Events
      def self.on_mainwindow_create(window)
        # make tab-notebooks
        #page = EmojiButtonsPage.new('ALL', EMOJI_MANAGER.all_emojis)
        label = Gtk::Label.new('ALL')
        #window.builder['tab_notebook'].append_page page, label

        #EMOJI_MANAGER.categories.each do |category, emojis|
        #  page = EmojiButtonsPage.new(category, emojis)
        #  label = Gtk::Label.new(category)
        #  window.builder['tab_notebook'].append_page page, label
        #end
      end
    end

    def show
      @builder['main_window'].show_all
    end

    def initialize
      # load .glade file
      @builder = Gtk::Builder.new
      @builder.add_from_file File.expand_path('../main_window.glade', __FILE__)

      # quit events
      @builder['main_window'].signal_connect 'delete_event' do
        Gtk::main_quit
      end
      @builder['main_window'].signal_connect 'destroy' do
        Gtk::main_quit
      end

      # register Events (see emojidex-editor.rb)
      @builder['btn_clip'].signal_connect 'clicked' do
        Events.on_clip_clicked
      end
      @builder['tgl_picture'].signal_connect 'toggled' do |btn|
        Events.on_picture_toggled btn.active?
      end

      # call create event
      Events.on_mainwindow_create self
    end
  end
end
