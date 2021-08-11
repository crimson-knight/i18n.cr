require "../spec_helper"

describe I18n::Backend::Yaml do
  backend = I18n::Backend::Yaml.new
  locales = %w(spec/locales/common spec/locales/common/subfolder)
  locales.each { |path| backend.load(path) }

  describe "%embed" do
    it "embeds files from given folder" do
      with_blank_translations do
        local_backend = I18n.backend.as(I18n::Backend::Yaml)
        local_backend.translations.clear
        local_backend.translations.should be_empty

        I18n::Backend::Yaml.embed(["spec/locales/common/subfolder"])

        local_backend.translations["en"].has_key?("subfolder_message").should be_true
        local_backend.translations["en"].has_key?("new_message").should be_false
      end
    end
  end

  describe "#load" do
    it "extends existing language file loading another one" do
      backend.translate("en", "new_message", count: 1).should eq("you have a message")
      backend.translate("en", "subfolder_message").should eq("subfolder message")
    end

    it "loads all available languages" do
      backend.available_locales.sort.should eq(%w(en pt ru))
    end

    it "loads specified file path" do
      local_backend = I18n::Backend::Yaml.new
      local_backend.load("spec/locales/common/en.yml")
      local_backend.available_locales.should eq(%w(en))
    end

    it "loads json file" do
      local_backend = I18n::Backend::Yaml.new
      local_backend.load("spec/locales/common/uk.json")
      local_backend.available_locales.should eq(%w(uk))
      local_backend.translate("uk", "new_message", count: 2).should eq("у вас 2 повідомлення")
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
      it { backend.translate("en", "messages.plural", {:attr => "b"}, count: 2).should eq("2 bs") }
    end

    it { backend.translate("en", "messages.with_2_arguments", {attr: "a", attr2: "b"}).should eq("a and b") }
    it { backend.translate("pt", "hello").should(eq("olá")) }

    it {
      # this usage is not recommended
      backend.translate("pt", "__formats__.date.day_names", iter: 1).should eq("Terça")
    }
  end

  describe "#exists?" do
    it { backend.exists?("en", "messages.with_2_arguments").should be_true }
    it { backend.exists?("pt", "hello").should be_true }
    it { backend.exists?("en", "hello").should be_false }
    it { backend.exists?("au", "hello").should be_false }

    context "with pluralization" do
      it { backend.exists?("pt", "new_message", 1).should be_true }
      it { backend.exists?("en", "messages.plural", 1).should be_true }

      it { backend.exists?("en", "messages.with_2_arguments", 1).should be_false }
    end
  end

  describe "#localize" do
    time = Time.local(2010, 10, 11, 12, 13, 14)

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
        backend.localize("pt", time, scope: :time).should(eq("12:13:14"))
      end
    end

    context "with date format" do
      it "date default format" do
        backend.localize("pt", time, scope: :date).should(eq("2010-10-11"))
      end

      it "date long format" do
        backend.localize("pt", time, scope: :date, format: "long").should(eq("Segunda, 11 de Outubro 2010"))
      end
    end

    it "format number to currency" do
      backend.localize("pt", 123.123, scope: :currency).should(eq("123,123€"))
    end
  end
end
