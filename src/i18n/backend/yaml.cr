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

        if tr && (iter = options[:iter]?) && tr.is_a? Array(YAML::Type)
          tr = tr[iter]
        end

        if options[:format]?
          tr.to_s
        else
          tr.to_s % options
        end
      end

      def localize(locale : String, object, scope = :number, **options) : String
        base_key = "__formats__."

        if object.is_a?(Time) && (scope == :time || scope == :date || scope == :datetime)

          base_key += scope.to_s + ((format = options[:format]?) ? ".formats." + format.to_s : ".formats.default" )

          format = translate(locale, base_key, format: true)
          format = format.to_s.gsub(/%[aAbBpP]/) do |match|
            case match
              when "%a" then translate(locale, "__formats__.date.abbr_day_names", iter: object.day_of_week.to_i, format: true)
              when "%A" then translate(locale, "__formats__.date.day_names", iter: object.day_of_week.to_i, format: true)
              when "%b" then translate(locale, "__formats__.date.abbr_month_names", iter: object.month, format: true)
              when "%B" then translate(locale, "__formats__.date.month_names", iter: object.month, format: true)
              when "%p" then translate(locale, "__formats__.time.#{object.hour < 12 ? :am : :pm}").upcase if object.responds_to? :hour
              when "%P" then translate(locale, "__formats__.time.#{object.hour < 12 ? :am : :pm}").downcase if object.responds_to? :hour
            end
          end
          return object.to_s(format)

        elsif object.is_a?(Number) && (scope == :number || scope == :currency)
          number = self.format_number(locale, object)

          if scope == :currency
            number = translate(locale, "__formats__.currency.format", format: true) % number
          end

          return number
        end

        # Don't know what to do, return the object
        object.to_s

      end

      private def load_file(filename)
        begin
          YAML.parse(File.read(filename))
        rescue e : YAML::ParseException
          raise InvalidLocaleData.new(filename, e.inspect)
        end
      end

      def format_number(locale : String, object : Number) : String

        value = object.to_s
        # get decimal separator
        dec_separator = translate(locale, "__formats__.number.decimal_separator")
        if (dec_separator)
          value = value.sub(Regex.new("\\."), dec_separator)
        end

        # ## set precision separator ###
        # split by decimal separator
        match = value.match(Regex.new("(\\d+)#{dec_separator}?(\\d+)?", Regex::Options::IGNORE_CASE))
        if (!match)
          return value
        end
        #match = match as Regex::MatchData

        integer = match[1]
        decimal = match[2]?

        precision_separator = translate(locale, "__formats__.number.precision_separator")
        new_value = ""
        counter = 0
        index = integer.size - 1
        while (index >= 0)
          if (counter >= 3)
            new_value = precision_separator + new_value
            counter = 0
          end

          new_value = integer[index].to_s + new_value

          index -= 1
          counter += 1
        end

        value = new_value
        if (decimal)
          value += dec_separator + decimal
        end

        return value

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
