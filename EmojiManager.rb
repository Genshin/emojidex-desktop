#
# emojiman.rb
#
require 'gtk3'
require 'emojidex-toolkit'

class << EMOJI_MANAGER = Object.new
  PICTURE_DIRECTORY = './png/'  # .png file root
  attr_reader :categories       # { String => [Emojidex::Emoji] }

  def initialize
    @converter = Emojidex::Converter.new
    @utf = Emojidex::UTF.new
    @categories = @utf.categories
    @picts = {}                   # { String => Gdk::Pixbuf }
    @reverse_lookup = {}
    @mutex = Mutex.new
  end

  # create & load pictures
  def get_picture(emoji_name)
    unless @picts[emoji_name]
      @mutex.synchronize do
        @converter.convert_from_name! @utf, PICTURE_DIRECTORY,
          emoji_name, { :size => :mdpi }
        emoji = @utf.where_name(emoji_name)
        pict = Gdk::Pixbuf.new(emoji.image_paths[0])
        @picts[emoji_name] = pict
        @reverse_lookup[pict] = emoji
      end
    end
    @picts[emoji_name]
  end

  def emojify_each(str)
    return to_enum(:emojify_each) unless block_given?
    @utf.emojify_each(str) {|item| yield item }
  end

  def all_emojis
    return @utf.to_a
  end

  def pic2emoji(pict)
    return @reverse_lookup[pict]
  end
end
EMOJI_MANAGER.instance_eval{ initialize }
