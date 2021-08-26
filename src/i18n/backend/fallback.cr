module I18n::Backend
  class Fallback < Base
    include Common

    getter backend : Base
    property fallbacks : Hash(String, String)

    delegate available_locales, load, to: backend

    def initialize(@backend : Base, @fallbacks : Hash(String, String))
      raise ArgumentError.new("At least one fallback should be specified") if @fallbacks.empty?
    end

    def initialize(@backend : Base, fallbacks : Array(String))
      raise ArgumentError.new("At least one fallback should be specified") if fallbacks.empty?

      @fallbacks = {} of String => String
      fallbacks[1..-1].each_with_index do |current, index|
        previous = fallbacks[index]
        @fallbacks[previous] = current
      end
    end

    def translate!(locale : String, key : String, options : Hash | NamedTuple?, count = nil, default = nil, iter = nil) : String
      error = nil
      fallbacks_for(locale) do |current_locale|
        error =
          begin
            return backend.translate!(current_locale, key, options, count, default, iter)
          rescue error : Exception
            error
          end
      end
      raise error.not_nil!
    end

    def exists?(locale : String, key : String, count = nil) : Bool
      fallbacks_for(locale) do |current_locale|
        return true if backend.exists?(current_locale, key, count)
      end
      false
    end

    def available_locales : Array(String)
      backend.available_locales
    end

    def load(*args)
      backend.load(*args)
    end

    private def fallbacks_for(locale : String)
      yield locale
      while true
        locale = fallbacks[locale]?
        if locale.is_a?(String)
          yield locale
        else
          break
        end
      end
    end
  end
end
