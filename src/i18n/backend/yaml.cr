require "yaml"

require "./base"

module I18n
  module Backend
    class Yaml < I18n::Backend::Base
      @translations = Hash(String, Hash(String, YAML::Type)).new

      def load(*args)
        if args[0].is_a?(String)
          files = Dir.glob(args[0] + "/*.yml")

          files.each do |file|
            lang = File.basename(file, ".yml")
            lang_data = load_file(file)
            @translations[lang] = Yaml.normalize(lang_data.as_h)
          end
        else
          raise ArgumentError.new("First argument should be a filename")
        end
      end

      def translate(locale : String, key : String, **options) : String
        if count = options[:count]?
          key += count == 1 ? ".one" : ".other"
        end

        tr = @translations[locale][key]?
        raise MissingTranslation.new(locale, key, options) unless tr

        tr.to_s % options
      end

      def localize(locale : String, object, format = :default, **options) : String
        ""
      end

      private def load_file(filename)
        begin
          YAML.parse(File.read(filename))
        rescue e : YAML::ParseException
          raise InvalidLocaleData.new(filename, e.inspect)
        end
      end

      def self.normalize(data : Hash, path : String = "", final = Hash(String, YAML::Type).new)
        data.keys.each do |k|
          newp = path.size == 0 ? k.to_s : path + "." + k.to_s
          newdata = data[k]
          if newdata.is_a?(Hash)
            self.normalize(newdata, newp, final)
          else
            final[newp] = newdata
          end
        end
        return final
      end
    end
  end
end
