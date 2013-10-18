require 'emojidex-toolkit'

Emojidex::Converter.convert_all! './png'

EMOJIDEX_UTF = Emojidex::UTF.new

def test_message(message)
  printf "source=%p\n", message
  printf "emojify=%p\n", EMOJIDEX_UTF.emojify(message)
  puts 'emojify_each:'
  EMOJIDEX_UTF.emojify_each message do |obj|
    p obj
  end
  puts "\n----- end of emojify_each"
end

test_message 'Hi!😃 🌀 comes here now, so I\'m :video_game:ing now!'
puts '#' * 79
test_message 'Hi!:smilee:cyclone: comes here now, so I\'m :video_game:ing now!'
