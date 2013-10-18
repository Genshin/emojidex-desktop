require 'emojidex-toolkit'

puts Emojidex::UTF.new.categories.to_json(JSON::State.new(
  indent: "\t",
  space: ' ',
  object_nl: "\n",
  array_nl: "\n",
))
