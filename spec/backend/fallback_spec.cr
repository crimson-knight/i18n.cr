require "../spec_helper"

describe I18n::Backend::Fallback do
  yaml_backend = I18n::Backend::Yaml.new
  yaml_backend.load("spec/locales/en-US.yml", "spec/locales/common/en.yml")
  backend = I18n::Backend::Fallback.new(yaml_backend, {"en-US" => "en"})

  describe "#initialize" do
    it "converts array of fallback codes into hash" do
      I18n::Backend::Fallback.new(yaml_backend, %w[en-US en pt]).fallbacks.should eq({"en-US" => "en", "en" => "pt"})
    end
  end

  describe "#translate" do
    it { backend.translate("en-US", "messages.with_2_arguments", {attr: "a", attr2: "b"}).should eq("a and b") }
    it { backend.translate("en-US", "hello").should eq("hey") }
    it { backend.translate("en", "thanks").should eq("thanks") }

    context "when translation is missing" do
      it "returns error message with path and language" do
        backend.translate("en-US", "missing2").should eq("[Missing translation : en#missing2]")
      end

      context "with default value" do
        it { backend.translate("en-US", "missing2", default: "Hi").should eq("Hi") }
      end
    end

    context "with pluralization" do
      it { backend.translate("en-US", "new_message", count: 1).should eq("you have got a message") }
    end
  end

  describe "#exists?" do
    it { backend.exists?("en-US", "hello").should be_true }
    it { backend.exists?("en-US", "messages.with_2_arguments").should be_true }
    it { backend.exists?("en-US", "missing").should be_false }

    context "with pluralization" do
      it { backend.exists?("en-US", "new_message", 1).should be_true }

      it { backend.exists?("en-US", "messages.with_2_arguments", 1).should be_false }
    end
  end

  describe "#available_locales" do
    it { backend.available_locales.should eq(%w[en-US en]) }
  end

  describe "#localize" do
    time = Time.local(2010, 10, 11, 12, 13, 14)

    it "format number to currency" do
      backend.localize("en-US", 123.123, scope: :currency).should eq("123,123$")
    end

    context "with number format" do
      it { backend.localize("en-US", 1234).should eq("1.234") }
      it { backend.localize("en-US", 123.123).should eq("123,123") }
    end

    context "with time format" do
      it "time default format" do
        backend.localize("en-US", time, scope: :time).should eq("12:13:14")
      end
    end

    context "with date format" do
      it "date default format" do
        backend.localize("en-US", time, scope: :date).should eq("10/11/2010")
      end

      it "date long format" do
        backend.localize("en-US", time, scope: :date, format: "long").should eq("Monday, 11 of October 2010")
      end
    end
  end

  describe "#load" do
    it "passes given pattern to underlying backend" do
      local_yaml_backend = I18n::Backend::Yaml.new
      local_backend = I18n::Backend::Fallback.new(local_yaml_backend, {"pt" => "en"})
      local_backend.load("spec/locales/pl.yml")
      local_yaml_backend.translations.keys.should eq(%w[pl])
    end
  end
end
