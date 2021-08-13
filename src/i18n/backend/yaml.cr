require "yaml"

require "./base"

module I18n
  module Backend
    class Yaml < I18n::Backend::Base
      include Common

      getter available_locales : Array(String)
      property translations

      @translations = Hash(String, Hash(String, YAML::Any)).new
      @available_locales = Array(String).new

      macro embed(dirs)
        {% for dir in dirs %}
          {{ run("./yaml_embed", dir) }}
        {% end %}
      end

      # Read files, normalize and merge all the translations
      def load(*args)
        if args[0].is_a?(String)
          extension = File.extname(args[0])
          pattern = extension.empty? ? File.join(args[0], "*.yml") : args[0]

          Dir.glob(pattern).each { |file| load_file(file) }
        else
          raise ArgumentError.new("First argument should be a filename")
        end
      end

      def translate!(locale : String, key : String, options : Hash | NamedTuple? = EMPTY_HASH, count = nil, default = nil, iter = nil) : String
        key = plural_key(key, locale, count)

        tr = @translations[locale][key]? || default
        raise MissingTranslation.new(locale, key) unless tr
        return tr[iter].to_s if tr && iter && tr.is_a?(YAML::Any)

        tr = tr.to_s
        tr = tr.sub(/\%{count}/, count) if count
        return tr unless options

        options.each { |attr, value| tr = tr.gsub(/\%{#{attr}}/, value) }
        tr
      end

      def exists?(locale : String, key : String, count = nil) : Bool
        translations.has_key?(locale) && translations[locale].has_key?(plural_key(key, locale, count))
      end

      private def load_file(path)
        case File.extname(path)
        when ".yml", ".json"
          load_yaml(path)
        end
      end

      private def load_yaml(path)
        lang = File.basename(path).split(".")[0]
        lang_data = read_yaml(path)
        return if lang_data.raw.nil?

        @translations[lang] ||= {} of String => YAML::Any
        @translations[lang].merge!(self.class.normalize(lang_data))
        @available_locales << lang unless @available_locales.includes?(lang)
      end

      private def read_yaml(filename)
        YAML.parse(File.read(filename))
      rescue e : YAML::ParseException
        raise InvalidLocaleData.new(filename, e.inspect)
      end

      # Flatten paths
      def self.normalize(data : YAML::Any, path : String = "", final = Hash(String, YAML::Any).new)
        data.as_h.keys.each do |k|
          newp = path.size == 0 ? k.to_s : path + "." + k.to_s
          newdata = data[k]

          if newdata.as_h?
            normalize(newdata, newp, final)
          else
            final[newp] = newdata
          end
        end

        final
      end
    end
  end
end
