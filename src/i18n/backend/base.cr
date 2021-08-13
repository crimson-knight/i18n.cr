module I18n
  module Backend
    abstract class Base
      EMPTY_HASH = {} of String => String

      abstract def load(*args)
      abstract def translate!(locale : String, key : String, opitions : Hash | NamedTuple?, count = nil, default = nil, iter = nil) : String
      abstract def exists?(locale : String, key : String, count = nil) : Bool
      abstract def localize(locale : String, object, scope = :number, format = nil) : String
      abstract def available_locales : Array(String)

      def translate(locale : String, key : String, options : Hash | NamedTuple? = EMPTY_HASH, count = nil, default = nil, iter = nil) : String
        translate!(locale, key, options, count, default, iter)
      rescue error : Exception
        key = plural_key(key, locale, count)
        I18n.exception_handler.call(error, locale, key, options, count, default)
      end

      private def plural_key(base_key : String, locale : String, count : Nil)
        base_key
      end

      private def plural_key(base_key : String, locale : String, count : Int)
        "#{base_key}.#{I18n.config.plural_rule_for(locale).call(count)}"
      end
    end
  end
end
