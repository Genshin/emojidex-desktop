#
# emojiman.rb
#
require 'gtk3'
require 'emojidex'
require 'emojidex-rasters'

class EmojiManager
  CACHE_DIRECTORY = ENV['HOME'] + '/.emojidex/cache/'  # cache root
  SEPARATOR = ':'

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

    work = ''

    str.chars do |char|
      if @collection.find_by_moji(char).nil?
        work << char
      else
        emojify(work) { |item| yield item }
        yield @collection.find_by_moji(char)
        work = ''
      end
    end

    emojify(work) { |item| yield item }
  end

  def emojify(str)
    work = ''

    # Too short
    if str.length < 3
      yield str
      return
    end

    # Search for the start-separator
    start_index = str.index(SEPARATOR)
    if start_index.nil?
      yield str
      return
    end

    # Before the first separator.
    yield str[0..start_index - 1] unless start_index == 0
    work << str[start_index..str.length - 1]

    # Until separator is not exist.
    while start_index != nil do
      # Search for the end-separator
      end_index = work[1..work.length - 1].index(SEPARATOR)
      break if end_index.nil?

      # String between the separator.
      code = work[0..end_index + 1]
      emoji = @collection.find_by_code(code[1..code.length - 2])

      # Whether this string is emoji code.
      if emoji.nil?
        yield work[0..end_index]
        work = work[end_index + 1..work.length - 1]
      else
        yield emoji
        work = work[end_index + 2..work.length - 1]
      end

      # Move to next start-separator.
      start_index = work.index(SEPARATOR)
    end

    # Insert the remaining characters.
    yield work
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
