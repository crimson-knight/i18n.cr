require "../spec_helper.cr"

describe I18n::Backend::Yaml do
  backend = I18n::Backend::Yaml.new
  locales = %w(spec/locales spec/locales/subfolder)
  locales.each { |path| backend.load(path) }

  describe "%embed" do
    pending "add" {}
  end

  describe "#load" do
    it "extends existing language file loading another one" do
      backend.translate("en", "new_message", count: 1).should eq("you have a message")
      backend.translate("en", "subfolder_message").should eq("subfolder message")
    end

    it "loads all available languages" do
      backend.available_locales.should eq(%w(en pt))
    end
  end

  describe "#translate" do
    context "when translation is missing" do
      context "with default value" do
        it { backend.translate("en", "hello", default: "Hi").should(eq("Hi")) }
      end

      it "returns error message with path and language" do
        backend.translate("pt", "missing").should(eq("[Missing translation : pt#missing]"))
        backend.translate("en", "missing2").should(eq("[Missing translation : en#missing2]"))
      end
    end

    it { backend.translate("pt", "hello").should(eq("olá")) }

    it "pluralization translate 1" do
      backend.translate("pt", "new_message", count: 1).should(eq("tem uma nova mensagem"))
    end

    it "pluralization translate 2" do
      tr = backend.translate("pt", "new_message", count: 2) % {count: 2}
      tr.should(eq("tem 2 novas mensagens"))
    end
  end

  describe "#localize" do
    time = Time.new(2010, 10, 11, 12, 13, 14)

    it "format number" do
      backend.localize("pt", 1234).should(eq("1.234"))
    end

    it "format number with decimals" do
      backend.localize("pt", 123.123).should(eq("123,123"))
    end

    it "format number to currency" do
      backend.localize("pt", 123.123, scope: :currency).should(eq("123,123€"))
    end

    it "time default format" do
      backend.localize("pt", time, scope: :time).should(eq(time.to_s("%H:%M:%S")))
    end

    it "date default format" do
      backend.localize("pt", time, scope: :date).should(eq(time.to_s("%Y-%m-%d")))
    end

    it "date long format" do
      backend.localize("en", time, scope: :date, format: "long").should(eq(time.to_s("%A, %d of %B %Y")))
    end
  end
end