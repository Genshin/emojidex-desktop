#
# emojiman.rb
#
require 'gtk3'
require 'emojidex'

class EmojiManager
  CACHE_DIRECTORY = ENV['HOME'] + '/.emojidex/cache/'  # cache root

  attr_reader :categories       # { String => [Emojidex::Emoji] }

  def initialize
    # TODO
    # @converter = Emojidex::Converter.new
    # @utf = Emojidex::UTF.new
    # @categories = @utf.categories
    @utf = []
    @utf << Emojidex::Emoji.new({moji: '🌠', code: 'shooting_star',
                                 code_ja: '流れ星', category: 'cosmos',
                                 unicode: '1f320', uri: '/dummy/uri'})
    @categories = ['cosmos']
    @picts = {}                   # { String => Gdk::Pixbuf }
    @reverse_lookup = {}
    @mutex = Mutex.new
  end

  # create & load pictures
  def get_picture(emoji_name)
    unless @picts[emoji_name]
      @mutex.synchronize do
        @converter.convert_from_name! @utf, CACHE_DIRECTORY,
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

EMOJI_MANAGER = EmojiManager.new
