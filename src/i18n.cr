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

  @@inner_config

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

  def translate(key : String, force_locale = config.locale, _throw = :throw, count = nil, default = nil, iter = nil) : String
    backend = config.backend
    locale = force_locale
    # handling = _throw

    raise I18n::ArgumentError.new if key.empty?

    begin
      backend.translate(locale, key, count: count, default: default)
    rescue e
      e.inspect
    end

    # if result.is_a?(MissingTranslation) && handling.is_a?(Proc(MissingTranslation, String, String, NamedTuple))
    #  handling(result, locale, key, options)
    # else
    # end
  end

  def translate(key : String, force_locale = config.locale, count = nil, default = nil, iter = nil, &block) : String
    puts "block"
    backend = config.backend
    locale = force_locale

    raise I18n::ArgumentError.new if key.empty?

    result =
      begin
        backend.translate(locale, key, count: count, default: default)
      rescue e
        e
      end

    if e.is_a?(MissingTranslation)
      (yield e).to_s
    else
      result.as(String)
    end
  end

  def localize(object, force_locale = config.locale, format = nil, scope = :number)
    result = 
      begin
        config.backend.localize(force_locale, object, format: format, scope: scope)
      rescue e
        e
      end

    if result.is_a?(Exception)
      result.inspect
    else
      result
    end
  end
end
