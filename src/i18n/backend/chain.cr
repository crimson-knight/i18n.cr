module I18n
  module Backend
    class Chain < Base
      include Common

      getter backends : Array(Base)

      def initialize(backends : Array(Base))
        raise ArgumentError.new("At least one back-end should be specified") if backends.empty?

        @backends = backends
      end

      def load(*args)
        backends.each(&.load(*args))
      end

      def translate!(locale : String, key : String, options : Hash | NamedTuple?, count = nil, default = nil, iter = nil) : String
        error = nil
        backends.each do |backend|
          error =
            begin
              return backend.translate!(locale, key, options, count, default, iter)
            rescue error : Exception
              error
            end
        end
        raise error.not_nil!
      end

      def exists?(locale : String, key : String, count = nil) : Bool
        backends.any?(&.exists?(locale, key, count))
      end

      def available_locales : Array(String)
        backends.flat_map(&.available_locales).uniq
      end
    end
  end
end
