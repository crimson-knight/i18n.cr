require "yaml"

puts ARGV
dir = ARGV[0]

puts "__backend__ = I18n.backend.as(I18n::Backend::Yaml)"

Dir.glob "#{dir}/*.yml" do |file|
  lang = File.basename file, ".yml"

  # compile time check to ensure yaml is well formatted
  content = File.read file
  YAML.parse content

  puts "lang_data = ::YAML.parse <<-I18nENDTOKEN"
  puts content
  puts "I18nENDTOKEN"

  puts <<-EOF
    if __backend__.translations["#{lang}"]?
      __backend__.translations["#{lang}"].merge!(I18n::Backend::Yaml.normalize(lang_data))
    else
      __backend__.available_locales << "#{lang}"
      __backend__.translations["#{lang}"] = I18n::Backend::Yaml.normalize(lang_data)
    end
  EOF
end
