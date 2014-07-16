#
# emojiman.rb
#
require 'gtk3'
require 'emojidex'
require 'emojidex-vectors'
require 'rsvg2'

class EmojiManager
  CACHE_DIRECTORY = ENV['HOME'] + '/.emojidex/cache/'  # cache root

  attr_reader :categories       # { String => [Emojidex::Emoji] }

  def initialize
    load_emoji(check_cache)

    # TODO
    # @converter = Emojidex::Converter.new
    # @utf = Emojidex::UTF.new
    # @categories = @utf.categories

    @picts = {}                   # { String => Gdk::Pixbuf }
    @reverse_lookup = {}
    @mutex = Mutex.new
  end

  # create & load pictures
  def get_picture(emoji_name)
    unless @picts[emoji_name]
      @mutex.synchronize do
        # TODO
        # @converter.convert_from_name! @utf, CACHE_DIRECTORY,
        #   emoji_name, { :size => :mdpi }
        # emoji = @utf.where_name(emoji_name)
        # pict = Gdk::Pixbuf.new(emoji.image_paths[0])
        pict = RSVG.pixbuf_from_file_at_size("#{CACHE_DIRECTORY}#{emoji_name}.svg", 16, 16)
        @picts[emoji_name] = pict
        # @reverse_lookup[pict] = emoji
        @reverse_lookup[pict] = @collection.find_by_code(emoji_name)
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

  def check_cache
    source_path = if File.exist?(CACHE_DIRECTORY)
                    CACHE_DIRECTORY
                  else
                    "#{Gem.loaded_specs['emojidex-vectors'].full_gem_path}/emoji/utf"
                  end
  end

  def load_emoji(source_path)
    @collection = Emojidex::Collection.new
    @collection.load_local_collection(source_path)
    @collection.cache! unless File.exist?(CACHE_DIRECTORY)

    @utf = @collection.emoji.values

    @categories = []
    @collection.categories.each do |category|
      @categories << [category.to_s, @collection.category(category).emoji.values]
    end
  end
end

EMOJI_MANAGER = EmojiManager.new
