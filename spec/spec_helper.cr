require "spec"
require "../src/i18n"

I18n.load_path += %w(spec/locales spec/locales/subfolder)
I18n.locale = "pt"
I18n.init
