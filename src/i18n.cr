require "./i18n/*"

module I18n
  extend self

  macro define_delegator(name)
    def {{name}}
      config.{{name}}
    end

    def {{name}}=(value)
      config.{{name}} = (value)
    end
  end

  @@inner_config

  # Gets I18n configuration object.
  def config
    @@inner_config ||= I18n::Config.new
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

  {% for name in %w(locale backend default_locale available_locales default_separator
                   exception_handler load_path) %}
    define_delegator({{name.id}})
  {% end %}

  def translate(key : String, **options) : String
    backend = config.backend
    locale = options[:force_locale]? || config.locale.to_s
    handling = options[:throw]? && :throw

    raise I18n::ArgumentError.new if key.empty?

    result = begin
      backend.translate(locale, key, **options)
    rescue e
      e
    end

    # if result.is_a?(MissingTranslation) && handling.is_a?(Proc(MissingTranslation, String, String, NamedTuple))
    #  handling(result, locale, key, options)
    # else
    if result.is_a?(Exception)
      result.inspect
    else
      result
    end
    # end
  end

  def localize(object, **options)
    backend = config.backend
    locale = options[:force_locale]? || config.locale.to_s

    result = begin
      backend.localize(locale, object, **options)
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
