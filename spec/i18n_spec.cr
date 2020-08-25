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

      context "with custom pluralization rule" do
        custom_plural_rule = ->(n : Int32) {
          case n
          when 0 then :zero
          when 1 then :one
          else        :other
          end
        }

        Spec.before_each do
          I18n.plural_rules["en"] = custom_plural_rule
          I18n.plural_rules["pt"] = custom_plural_rule
        end

        Spec.after_each do
          I18n.plural_rules.clear
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

        it "pluralization translate 0 with force_locale" do
          I18n.translate("new_message", count: 0, force_locale: "en").should(eq("you have no messages"))
        end

        it "pluralization translate 0 with with_locale" do
          (I18n.with_locale("en") { I18n.translate("new_message", count: 0) }).should(eq("you have no messages"))
        end
      end
    end

    it { I18n.translate("hello").should(eq("olá")) }
  end

  describe ".localize" do
    time = Time.local(2019, 7, 14, 20, 1, 3)

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
      I18n.localize(time, scope: :time).should(eq("20:01:03"))
    end

    it "date default format" do
      I18n.localize(time, scope: :date).should(eq("2019-07-14"))
    end

    it "date long format" do
      I18n.localize(time, scope: :date, force_locale: "en", format: "long").should(eq("Sunday, 14 of July 2019"))
    end

    it { I18n.localize(time, "en", :date, "long").should(eq("Sunday, 14 of July 2019")) }
  end

  describe ".with_locale" do
    it "temporarity sets the given locale" do
      I18n.locale = "en"

      I18n.locale.should eq("en")
      I18n.translate("thanks").should eq("thanks")

      (I18n.with_locale("pt") { I18n.translate("thanks") }).should(eq("obrigado"))

      I18n.locale.should eq("en")
      I18n.translate("thanks").should eq("thanks")
    end
  end
end
