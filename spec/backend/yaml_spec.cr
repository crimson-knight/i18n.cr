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
      backend.available_locales.sort.should eq(%w(en pt))
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

    context "with pluralization" do
      it { backend.translate("pt", "new_message", count: 1).should(eq("tem uma nova mensagem")) }
      it { backend.translate("en", "messages.plural", {attr: "a"}, count: 1).should eq("1 a") }

      it { backend.translate("pt", "new_message", count: 2).should(eq("tem 2 novas mensagens")) }
      it { backend.translate("en", "messages.plural", { :attr => "b" }, count: 2).should eq("2 bs") }
    end

    it { backend.translate("en", "messages.with_2_arguments", {attr: "a", attr2: "b"}).should eq("a and b") }
    it { backend.translate("pt", "hello").should(eq("olá")) }
    it { backend.translate("pt", "__formats__.date.day_names", iter: 2).should eq("Terça") }
  end

  describe "#localize" do
    time = Time.new(2010, 10, 11, 12, 13, 14)

    context "with number format" do
      it { backend.localize("pt", 123).should(eq("123")) }
      it { backend.localize("pt", 1234).should(eq("1.234")) }
      it { backend.localize("pt", 12345).should(eq("12.345")) }
      it { backend.localize("pt", 123456).should(eq("123.456")) }
      it { backend.localize("pt", 1234567).should(eq("1.234.567")) }
      it { backend.localize("pt", 12345678).should(eq("12.345.678")) }
      it { backend.localize("pt", 123.123).should(eq("123,123")) }

      it { backend.localize("pt", 1234.123, :time).should(eq("1234.123")) }
    end

    context "with time format" do
      it "time default format" do
        backend.localize("pt", time, scope: :time).should(eq(time.to_s("%H:%M:%S")))
      end
    end

    context "with date format" do
      it "date default format" do
        backend.localize("pt", time, scope: :date).should(eq(time.to_s("%Y-%m-%d")))
      end

      it "date long format" do
        backend.localize("en", time, scope: :date, format: "long").should(eq(time.to_s("%A, %d of %B %Y")))
      end
    end

    it "format number to currency" do
      backend.localize("pt", 123.123, scope: :currency).should(eq("123,123€"))
    end
  end
end