require "yaml"

puts ARGV
dir = ARGV[0]

puts "backend = I18n.backend.as(I18n::Backend::Yaml)"

files = Dir.glob "#{dir}/*.yml" do |file|
  lang = File.basename file, ".yml"

  # compile time check to ensure yaml is well formated
  content = File.read file
  YAML.parse content

  puts "lang_data = ::YAML.parse <<-I18nENDTOKEN"
  puts content
  puts "I18nENDTOKEN"
  puts "backend.translations[\"#{lang}\"] = I18n::Backend::Yaml.normalize(lang_data)"
  puts "backend.available_locales << \"#{lang}\""
end
