module I18n::Backend
  module Common
    # Localize a number or a currency
    # Use the format if given
    # scope can be one of `:number` ( default ), `:currency`
    #
    # Following keys are required :
    #
    # ```yaml
    # __formats__:
    #       number:
    #         decimal_separator: ','
    #       precision_separator: '.'
    #
    #       currency:
    #         symbol: '€'
    #       name: 'euro'
    #       format: '%s€'
    # ```
    def localize(locale : String, object : Number, scope = :number, format = nil) : String
      return object.to_s if scope != :number && scope != :currency

      number = format_number(locale, object)
      if scope == :currency
        number = translate(locale, "__formats__.currency.format", {"amount" => number})
      end

      number
    end

    # Localize a date or a datetime using the *format* if provided.
    # *scope* can be one of :time ( default ), :date, :datetime
    #
    # NOTE: According to ISO 8601, Monday is the first day of the week
    #
    # Following keys are required :
    # ```yaml
    # __formats__:
    #       date:
    #         formats:
    #         default: "%Y-%m-%d"
    #       long: "%A, %d of %B %Y"
    #
    #       month_names: [January, February, March, April, May, June, July, August, September, October, November, December]
    #       abbr_month_names: [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
    #
    #       day_names: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
    #       abbr_day_names: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    #
    #       time:
    #         formats:
    #             default: "%I:%M:%S %p"
    # ```
    def localize(locale : String, object : Time, scope = :time, format = nil) : String
      base_key = "__formats__." + scope.to_s + (format ? ".formats." + format.to_s : ".formats.default")

      format = translate(locale, base_key)
      format = format.to_s.gsub(/%[aAbBpP]/) do |match|
        case match
        when "%a" then translate(locale, "__formats__.date.abbr_day_names", iter: object.day_of_week.value - 1)
        when "%A" then translate(locale, "__formats__.date.day_names", iter: object.day_of_week.value - 1)
        when "%b" then translate(locale, "__formats__.date.abbr_month_names", iter: object.month - 1)
        when "%B" then translate(locale, "__formats__.date.month_names", iter: object.month - 1)
        when "%p" then translate(locale, "__formats__.time.#{object.hour < 12 ? :am : :pm}").upcase if object.responds_to? :hour
        when "%P" then translate(locale, "__formats__.time.#{object.hour < 12 ? :am : :pm}").downcase if object.responds_to? :hour
        end
      end
      object.to_s(format)
    end

    # Invokes `#to_s` on the `object` ignoring `scope` and `format`
    def localize(locale : String, object, scope = :number, format = nil) : String
      # Don't know what to do, return the object
      object.to_s
    end

    # :nodoc:
    # see https://github.com/whity/crystal-i18n/blob/96defcb7266c7b526ab6f1a5648e3b5b240b6d58/src/i18n/i18n.cr
    private def format_number(locale : String, object : Number)
      value = object.to_s
      # get decimal separator
      dec_separator = translate(locale, "__formats__.number.decimal_separator")

      value = value.sub(/\./, dec_separator) if dec_separator

      # ## set precision separator ##
      # split by decimal separator
      match = value.match(/(\d+)#{dec_separator}?(\d+)?/)

      return value unless match

      integer = match[1]
      decimal = match[2]?

      String.build do |io|
        precision_separator = translate(locale, "__formats__.number.precision_separator")

        leading_digits = integer.size % 3
        precision_counter = leading_digits == 0 ? 0 : 3 - leading_digits
        index = integer.size - 1

        integer.each_char do |char|
          io << char

          if precision_counter == 2 && index != 0
            io << precision_separator
            precision_counter = 0
          else
            precision_counter += 1
          end
          index -= 1
        end

        io.print dec_separator, decimal if decimal
      end
    end
  end
end
