require "../spec_helper"

describe I18n::Backend::Chain do
  backend1 = I18n::Backend::Yaml.new
  backend2 = I18n::Backend::Yaml.new
  backend1.load("spec/locales/common/en.yml")
  backend2.load("spec/locales/pl.yml")
  backend = I18n::Backend::Chain.new([backend1, backend2] of I18n::Backend::Base)

  describe "#translate" do
    it { backend.translate("en", "messages.with_2_arguments", {attr: "a", attr2: "b"}).should eq("a and b") }
    it { backend.translate("pl", "thanks").should eq("Dziękuję") }

    context "when translation is missing" do
      it "returns error message with path and language" do
        backend.translate("pl", "missing2").should eq("[Missing translation : pl#missing2]")
      end

      context "with default value" do
        it { backend.translate("en", "hello", default: "Hi").should eq("Hi") }
      end
    end

    context "with pluralization" do
      it { backend.translate("pl", "new_message", count: 1).should eq("masz 1 wiadomośćу") }
    end
  end

  describe "#exists?" do
    it { backend.exists?("en", "messages.with_2_arguments").should be_true }
    it { backend.exists?("pl", "hello").should be_true }
    it { backend.exists?("en", "hello").should be_false }

    context "with pluralization" do
      it { backend.exists?("pl", "new_message", 1).should be_true }
      it { backend.exists?("en", "messages.plural", 1).should be_true }

      it { backend.exists?("en", "messages.with_2_arguments", 1).should be_false }
    end
  end

  describe "#available_locales" do
    it { backend.available_locales.should eq(%w[en pl]) }
  end

  describe "#localize" do
    time = Time.local(2010, 10, 11, 12, 13, 14)

    it "format number to currency" do
      backend.localize("en", 123.123, scope: :currency).should eq("123,123€")
      backend.localize("pl", 123.123, scope: :currency).should eq("123.123zł")
    end

    context "with number format" do
      it { backend.localize("en", 1234).should eq("1.234") }
      it { backend.localize("pl", 1234).should eq("1,234") }

      it { backend.localize("en", 123.123).should eq("123,123") }
      it { backend.localize("pl", 123.123).should eq("123.123") }
    end

    context "with time format" do
      it "time default format" do
        backend.localize("en", time, scope: :time).should eq("12:13:14")
        backend.localize("pl", time, scope: :time).should eq("12:13:14")
      end
    end

    context "with date format" do
      it "date default format" do
        backend.localize("en", time, scope: :date).should eq("2010-10-11")
        backend.localize("pl", time, scope: :date).should eq("11.10.2010")
      end

      it "date long format" do
        backend.localize("en", time, scope: :date, format: "long").should eq("Monday, 11 of October 2010")
        backend.localize("pl", time, scope: :date, format: "long").should eq("poniedziałek, 11 Październik 2010")
      end
    end
  end

  describe "#load" do
    it "passes given pattern to all underlying backends" do
      backends = [I18n::Backend::Yaml.new, I18n::Backend::Yaml.new] of I18n::Backend::Base
      local_backend = I18n::Backend::Chain.new(backends)
      local_backend.load("spec/locales/pl.yml")
      backends[0].as(I18n::Backend::Yaml).translations.keys.should eq(%w[pl])
      backends[1].as(I18n::Backend::Yaml).translations.keys.should eq(%w[pl])
    end
  end
end
