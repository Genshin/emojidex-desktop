require 'gtk3'

# reads .glade, makes a window from it, and shows.
class MainWindow
  attr_reader :builder

  def show
    @builder['main_window'].show_all
  end

  def initialize
    # load .glade file
    @builder = Gtk::Builder.new
    @builder.add_from_file 'main_window.glade'

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
