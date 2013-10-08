#
# emojiman.rb
#
#     Loading JSON files, and pictures
#

require 'gtk3'
require 'json'

# Loading JSONs
CATEGORY_NAMES = JSON.parse(IO.read('category.json'))
EMOJIS = JSON.parse(IO.read('index.json'))

# Loading Pictures, and adding 'picture' to the Hash
EMOJIS.each do |emoji|
	emoji['picture'] = Gdk::Pixbuf.new("./png20/#{emoji['name']}.png")
end
