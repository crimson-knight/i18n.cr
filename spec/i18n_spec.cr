require "./spec_helper"

describe I18n do
  describe ".available_profiles" do
    it "should return the available locales" do
      I18n.available_locales.sort.should eq ["en", "pt"]
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

    context "with pluralization" do
      context "with default pluralization rule" do
        it "pluralization translate 0" do
          I18n.translate("new_message", count: 0).should(eq("tem 0 novas mensagens"))
        end

        it "pluralization translate 1" do
          I18n.translate("new_message", count: 1).should(eq("tem uma nova mensagem"))
        end

        it "pluralization translate 2" do
          tr = I18n.translate("new_message", count: 2)
          tr.should(eq("tem 2 novas mensagens"))
        end
      end

      context "with custom pluralization rule" do
        Spec.before_each do
          I18n.plural_rule = ->(n : Int32) {
            case n
            when 0 then :zero
            when 1 then :one
            else :other
            end
          }
        end

        Spec.after_each do
          I18n.plural_rule = nil
        end

        it "pluralization translate 0" do
          I18n.translate("new_message", count: 0).should(eq("não tem mensagens"))
        end

        it "pluralization translate 1" do
          I18n.translate("new_message", count: 1).should(eq("tem uma nova mensagem"))
        end

        it "pluralization translate 2" do
          tr = I18n.translate("new_message", count: 2)
          tr.should(eq("tem 2 novas mensagens"))
        end
      end
    end

    it { I18n.translate("hello").should(eq("olá")) }
  end

  describe ".localize" do
    time = Time.now

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
      I18n.localize(time, scope: :time).should(eq(time.to_s("%H:%M:%S")))
    end

    it "date default format" do
      I18n.localize(time, scope: :date).should(eq(time.to_s("%Y-%m-%d")))
    end

    it "date long format" do
      I18n.localize(time, scope: :date, force_locale: "en", format: "long").should(eq(time.to_s("%A, %d of %B %Y")))
    end

    it { I18n.localize(time, "en", :date, "long").should(eq(time.to_s("%A, %d of %B %Y"))) }
  end

  describe ".with_locale" do
    Spec.before_each do
      I18n.locale = "en"
    end

    it "temporarity sets the given locale" do
      I18n.locale.should eq("en")
      I18n.translate("thanks").should eq("thanks")

      (I18n.with_locale("pt") { I18n.translate("thanks") }).should(eq("obrigado"))

      I18n.locale.should eq("en")
      I18n.translate("thanks").should eq("thanks")
    end
  end
end
