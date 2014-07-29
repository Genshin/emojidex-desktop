#
# emojiman.rb
#
require 'gtk3'
require 'emojidex'
require 'emojidex-rasters'

class EmojiManager
  CACHE_DIRECTORY = ENV['HOME'] + '/.emojidex/cache/'  # cache root

  attr_reader :categories       # { String => [Emojidex::Emoji] }

  def initialize
    load_emoji

    @picts = {}                   # { String => Gdk::Pixbuf }
    @reverse_lookup = {}
    @mutex = Mutex.new
  end

  # create & load pictures
  def get_picture(emoji_name)
    unless @picts[emoji_name]
      @mutex.synchronize do
        pict = Gdk::Pixbuf.new("#{CACHE_DIRECTORY}/px16/#{emoji_name}.png")
        @picts[emoji_name] = pict
        @reverse_lookup[pict] = @collection.find_by_code(emoji_name)
      end
    end
    @picts[emoji_name]
  end

  def emojify_each(str)
    return to_enum(:emojify_each) unless block_given?
    emojify_each(str) {|item| yield item }
    # @utf.emojify_each(str) {|item| yield item }
  end

  def emojify_each(str)
    str.chars do |char|
      yield @collection.find_by_moji(char)
    end
  end

  def all_emojis
    return @utf.to_a
  end

  def pic2emoji(pict)
    return @reverse_lookup[pict]
  end

  def load_emoji
    @collection = Emojidex::Collection.new

    if File.exist?("#{CACHE_DIRECTORY}/emoji.json")
      then @collection.load_local_collection(CACHE_DIRECTORY)
      else create_cache
    end

    @utf = @collection.emoji.values

    @categories = []
    @collection.categories.each do |category|
      @categories << [category.to_s, @collection.category(category).emoji.values]
    end
  end

  def create_cache
    gem_path = Gem.loaded_specs['emojidex-rasters'].full_gem_path
    @collection.load_local_collection("#{gem_path}/emoji/utf")
    @collection.cache!({sizes: get_sizes})
    @collection.load_local_collection("#{gem_path}/emoji/extended")
    @collection.cache!({sizes: get_sizes})
  end

  def get_sizes
    sizes = []
    keys = Emojidex::Defaults.sizes.keys
    keys.each do |key|
      sizes << key.to_s
    end
    sizes
  end
end

EMOJI_MANAGER = EmojiManager.new
