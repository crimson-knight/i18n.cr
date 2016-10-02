module I18n
  module Backend
    abstract class Base
      abstract def load(*args)
      abstract def translate(locale : String, key : String, **options) : String
      abstract def localize(locale : String, object, type = :default, **options) : String
    end
  end
end
