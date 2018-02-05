require "./i18n/*"

module I18n
  extend self

  macro define_delegators(names)
    {% for name in names %}
      def {{name.id}}
        config.{{name.id}}
      end

      def {{name.id}}=(value)
        config.{{name.id}} = (value)
      end
    {% end %}
  end

  # Gets I18n configuration object.
  def config
    @@inner_config ||= Config.new
  end

  # Sets I18n configuration object.
  def config=(value)
    @@inner_config = value
  end

  def init
    load_path.each do |path|
      config.backend.load(path)
    end
  end

  define_delegators(%w(locale backend default_locale available_locales default_separator exception_handler load_path))

  def translate(key : String, options : Hash | NamedTuple? = nil, force_locale = config.locale, count = nil, default = nil, iter = nil) : String
    raise I18n::ArgumentError.new if key.empty?

    backend = config.backend

    begin
      backend.translate(force_locale, key, options: options, count: count, default: default)
    rescue e
      e.inspect
    end

    # if result.is_a?(MissingTranslation) && handling.is_a?(Proc(MissingTranslation, String, String, NamedTuple))
    #  handling(result, locale, key, options)
    # else
    # end
  end

  def localize(object, force_locale = config.locale, *args, **options)
    config.backend.localize(force_locale, object, *args, **options)
  rescue e
    e.inspect
  end
end
