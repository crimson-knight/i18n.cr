module I18n
  # Handles exceptions raised in the backend. All exceptions except for
  # MissingTranslationData exceptions are re-thrown. When a MissingTranslationData
  # was caught the handler returns an error message string containing the key/scope.
  # Note that the exception handler is not called when the option :throw was given.
  class ExceptionHandler
    def call(exception, locale, key, options)
      case exception
      when MissingTranslation
        exception.message
      when Exception
        raise exception
      else
        throw :exception, exception
      end
    end
  end

  class ArgumentError < ::ArgumentError; end

  class InvalidLocale < ArgumentError
    getter :locale

    def initialize(@locale : Symbol | String)
      super "#{locale.inspect} is not a valid locale"
    end
  end

  class InvalidLocaleData < ArgumentError
    getter :filename

    def initialize(@filename : String, @exception_message : String)
      super "can not load translations from #{filename}: #{exception_message}"
    end
  end

  class MissingTranslation < ArgumentError
    def initialize(@locale : String, @key : String)
    end

    def message
      "[Missing translation : #{@locale}\##{@key}]"
    end

    def to_s
      message
    end
  end

  class InvalidPluralizationData < ArgumentError
    getter :entry, :count

    def initialize(entry, count)
      @entry, @count = entry, count
      super "translation data #{entry.inspect} can not be used with :count => #{count}"
    end
  end

  class MissingInterpolationArgument < ArgumentError
    getter :key, :values, :string

    def initialize(key, values, string)
      @key, @values, @string = key, values, string
      super "missing interpolation argument #{key.inspect} in #{string.inspect} (#{values.inspect} given)"
    end
  end

  class ReservedInterpolationKey < ArgumentError
    getter :key, :string

    def initialize(key, string)
      @key, @string = key, string
      super "reserved key #{key.inspect} used in #{string.inspect}"
    end
  end

  class UnknownFileType < ArgumentError
    getter :type, :filename

    def initialize(@type : String, @filename : String)
      super "can not load translations from #{@filename}, the file type #{@type} is not known"
    end
  end
end
