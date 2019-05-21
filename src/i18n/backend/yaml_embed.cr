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

  puts <<-EOF
    if backend.translations[\"#{lang}\"]?
      backend.translations[\"#{lang}\"].merge!(I18n::Backend::Yaml.normalize(lang_data))
    else
      backend.translations[\"#{lang}\"] = I18n::Backend::Yaml.normalize(lang_data)
    end

    backend.available_locales << \"#{lang}\"
  EOF
end
