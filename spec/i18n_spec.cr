require "./spec_helper"

describe I18n do
  describe ".available_profiles" do
    it "should return the available locales" do
      I18n.available_locales.should eq ["en", "pt"]
    end
  end

  describe ".translate" do
    context "when translation is missing" do
      it "is a missing translation" do
        I18n.translate("missing").should(eq("[Missing translation : pt#missing]"))
        I18n.translate("missing2", force_locale: "en").should(eq("[Missing translation : en#missing2]"))
      end

      it "should replace by default value" do
        I18n.translate("hello", force_locale: "en", default: "Hi").should(eq("Hi"))
      end
    end

    it "translate" do
      I18n.translate("hello").should(eq("olá"))
    end

    it "pluralization translate 1" do
      I18n.translate("new_message", count: 1).should(eq("tem uma nova mensagem"))
    end

    it "pluralization translate 2" do
      tr = I18n.translate("new_message", count: 2) % {count: 2}
      tr.should(eq("tem 2 novas mensagens"))
    end
  end

  describe ".localize" do
    it "format number" do
      I18n.localize(1234).should(eq("1.234"))
    end

    it "format number with decimals" do
      I18n.localize(123.123).should(eq("123,123"))
    end

    it "format number to currency" do
      I18n.localize(123.123, scope: :currency).should(eq("123,123€"))
    end

    it "time default format" do
      time = Time.now
      I18n.localize(time, scope: :time).should(eq(time.to_s("%H:%M:%S")))
    end

    it "date default format" do
      time = Time.now
      I18n.localize(time, scope: :date).should(eq(time.to_s("%Y-%m-%d")))
    end

    it "date long format" do
      time = Time.now
      I18n.localize(time, scope: :date, force_locale: "en", format: "long").should(eq(time.to_s("%A, %d of %B %Y")))
    end
  end
end
