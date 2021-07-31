module I18n
  module Backend
    abstract class Base
      abstract def load(*args)
      abstract def translate(locale : String, key : String, opitions : Hash | NamedTuple?, count = nil, default = nil, iter = nil) : String
      abstract def exists?(locale : String, key : String, count = nil) : Bool
      abstract def localize(locale : String, object, scope = :number, format = nil) : String
      abstract def available_locales : Array(String)
    end
  end
end
