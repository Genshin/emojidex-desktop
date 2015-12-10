Gem::Specification.new do |s|
  s.name        = 'emojidex-desktop'
  s.version     = '0.1.0'
  s.license     = "GNU GPL v3"
  s.summary     = "Desktop client and tools for emojidex"
  s.description = ""
  s.authors     = ["Rei Kagetsuki"]
  s.email       = 'zero@genshin.org'
  s.files       = Dir.glob('emoji/**/*') +
                  Dir.glob('lib/**/*.rb') +
                  Dir.glob('bin/**/*.rb') +
                  ['emojidex-desktop.gemspec']
  s.homepage    = 'https://www.emojidex.com/'

  s.executables << 'emojidex'

  s.add_dependency 'emojidex', '~> 0.1'
  s.add_dependency 'gtk3', '~> 3.0'
end
