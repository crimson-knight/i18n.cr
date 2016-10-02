require "./spec_helper"

describe I18n do
  I18n.load_path += ["spec/locales"]
  I18n.locale = "pt"
  I18n.init

  it "translate" do
    I18n.translate("hello").should(eq("olá"))
  end

  it "pluralization translate 1" do
    I18n.translate("new_message", count: 1).should(eq("tem uma nova mensagem"))
  end

  it "pluralization translate 2" do
    I18n.translate("new_message", count: 2).should(eq("tem 2 novas mensagens"))
  end

  # it "format number" do
  #  I18n.number(1234.to_s).should(eq("1.234"))
  # end

  # it "format number with decimals" do
  #  I18n.number(123.123.to_s).should(eq("123,123"))
  # end

  # it "format number to currency" do
  #  I18n.currency(123.123.to_s).should(eq("€123,123"))
  # end

  # it "time default format" do
  #  time = Time.now
  #  I18n.time(time).should(eq(time.to_s("%H:%M:%S")))
  # end

  # it "date default format" do
  #  time = Time.now
  #  I18n.date(time).should(eq(time.to_s("%Y-%m-%d")))
  # end

  # it "date long format" do
  #  time = Time.now
  #  I18n.date(time, locale: "en", format: "long").should(eq(time.to_s("%A, %d of %B %Y")))
  # end
end
