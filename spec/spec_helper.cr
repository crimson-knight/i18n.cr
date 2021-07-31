require "spec"
require "../src/i18n"

I18n.load_path += %w(spec/**)
I18n.init

Spec.before_each { I18n.locale = "pt" }

macro with_blank_translations
  __temp_backend__ = I18n.backend
  I18n.backend = I18n::Backend::Yaml.new
  begin
    {{yield}}
  ensure
    I18n.backend = __temp_backend__
  end
end
