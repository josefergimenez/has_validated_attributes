# frozen_string_literal: true

begin
  require "rspec"
  require "shoulda-matchers"
rescue LoadError => e
  raise <<-ERROR_MSG
#{ e.path } is not loaded but is required when loading "has_validated_attributes/rspec"!

Do you need to `gem install #{ e.path }`?
ERROR_MSG
end

Dir[Rails.root.join("spec/support/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.extend Module.new {
    def has_validated_attribute(type, attr, *args, &block)
      it_behaves_like "#{ type.gsub("_", " ") } attribute", attr, *args, &block
    end

    # Provide dynamic methods wrappers to shared behaviors.
    #
    #=== Examples
    #  has_validated_name_field(:first_name)      # Same as `it_behaves_like "name attribute", :first_name`
    #  has_validated_zip_code_field(:first_name)  # Same as `it_behaves_like "zip code field", :first_name`
    def method_missing(name, *args, &block)
      if /\Ahas_validated_(?<type>\w*)_attribute\Z/ =~ name
        has_validated_attribute(type, *args, &block)
      else
        super
      end
    end
  }
end

#= Load shared examples
#   it_behaves_like "name attribute", :first_name
#   it_behaves_like "name attribute", :first_name, 10
RSpec.shared_examples_for "name attribute" do |attr, length: HasValidatedAttributes.name_format[:maximum_length]|
  it { should validate_length_of(attr).is_at_least(0) }
  it { should validate_length_of(attr).is_at_most(length) }

  [
    "A", "z", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    "{", "}", "?", "+", "[", "]", "/", "\\", "-", "_", "<", ">",
    "k c", "- H-", " t", "& u", "21 ", "brok", ">*", "< test"
  ].
    select { |str| str.length <= length }.
    each do |str|
      it { should allow_value(str).for(attr) }
    end

  ["\e1B", "\cF", "Hello\nWorld", "\eHey", "Oh\cFNo, it's a control char!"].
    select { |str| str.length <= length }.
    each do |str|
      it { should_not allow_value(str).for(attr).with_message(HasValidatedAttributes.name_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
    end
end

RSpec.shared_examples_for "username attribute" do |attr|
  it { should validate_length_of(attr).is_at_least(HasValidatedAttributes.username_format[:length][:within].min) }
  it { should validate_length_of(attr).is_at_most(HasValidatedAttributes.username_format[:length][:within].max) }

  ["kansascity", "kansascity@org1", "kansas.city@org1", "kansas_city@org1", "kansas-city", "1kc.-_@"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  [">*,.<><", "<<< test", "Kansas City", "-- Hey --", "& youuuu", "21 Jump"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.username_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "email attribute" do |attr|
  it { should validate_length_of(attr).is_at_most(HasValidatedAttributes.email_format[:length][:maximum]) }

  ["abc@example.com", "Abc@example.com", "aBC@example.com", "abc.123@example.com", "mo'reilly@example.com", "ro'sullivan@example.com", "abc@example.comar"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["Abc.example.com", "A@b@c@example.com", "()[]\;:,<>@example.com", "A@b@c@example..com"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.email_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "domain attribute" do |attr|
  it { should validate_length_of(attr).is_at_most(HasValidatedAttributes.domain_format[:length][:maximum]) }

  ["test.com", "hey.com", "dynamicadvisorsgroup.com", "advisorsexcel.com"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  [">*", "<test", "test-er"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.domain_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "middle initial attribute" do |attr|
  ["a", "A"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["k c", "55555", "55555-5555", "55555 5555", "55555.5555", "(888)88-9999", " ,-99999"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.middle_initial_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "zipcode attribute" do |attr|
  ["11111", "333333333"].each do |zip|
    it { should allow_value(zip).for(attr) }
  end

  ["5555", "5555555555", "-99999"].each do |zip|
    it { should_not allow_value(zip).for(attr).with_message(HasValidatedAttributes.zipcode_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "phone number attribute" do |attr, normalized: false|
  ["9134456677", "5444456677", "9134466677 ", " 2134456677 "].each do |phone|
    it { should allow_value(phone).for(attr) }
  end

  [">*", "< test", "www.test..com", "www.test.c", "www-test.com", "abc", "123", "&*()", "www.test-com"].each do |phone|
    it { should_not allow_value(phone).for(attr).with_message(HasValidatedAttributes.phone_number_format[:numericality][:message]) }
  end

  ["913 345 6677", "613-445-6677", "983445-6677", " 913-4256677", "(888)8888888", "903-445 6627", "913-4556677", "513.445-6677", "555.555.8888"].each do |phone|
    it { send(normalized ? :should : :should_not, allow_value(phone).for(attr).with_message(HasValidatedAttributes.phone_number_format[:numericality][:message])) }
  end
end

RSpec.shared_examples_for "phone extension attribute" do |attr|
  ["123", "123456", "123x4", "1x2x3"].each do |ext|
    it "should allow '#{ ext }' for #{ attr }" do
      should allow_value(ext).for(attr)
    end
  end

  ["-1", "qwert", "x123", "123x", "X123", "123X"].each do |ext|
    it "should not allow '#{ ext }' for #{ attr }" do
      should_not allow_value(ext).for(attr).with_message(HasValidatedAttributes.phone_extension_format[:format][:message].call(nil, attribute: attr.to_s.humanize))
    end
  end
end

RSpec.shared_examples_for "url attribute" do |attr, allowed: nil, disallowed: nil|
  (allowed || [
    "http://www.example.com", "http://www.example.com:8001", "http://www.exmple.com/1/abc?test=test",
    "http://finane.example.com", "http://www.example.com/1/abc?test=test", "http://fiance.example.com", "http://finance.example.com.ag"
  ]).each do |url|
    it { should allow_value(url).for(attr) }
  end

  (disallowed || [
    "finance.example.com", "www.example.com", ">*", "< test",
    "www.test..com", "www.test.c", "www-test.com", "abc", "123", "&*()", "www.test-com"
  ]).each do |url|
    it { should_not allow_value(url).for(attr).with_message(HasValidatedAttributes.url_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "positive percent attribute" do |attr|
  ["100", "99", "1", "44", "99.999", "99.9999", "0.001"].each do |percent|
    it { should allow_value(percent).for(attr) }
  end

  ["100.001", "0.22222", "abc", "&", "-44", "-44.4", "-44.4444"].each do |percent|
    it { should_not allow_value(percent).for(attr) }
  end
end

RSpec.shared_examples_for "percent attribute" do |attr|
  ["100", "99", "1", "44", "99.999", "99.9999", "0.001", "-100", "-99", "-1", "-44", "-99.999", "-0.001"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["100.001", "0.22222", "-100.001", "abc", "&"].each do |value|
    it { should_not allow_value(value).for(attr) }
  end
end

RSpec.shared_examples_for "positive comparative percent attribute" do |attr|
  ["1000", "999", "10", "444", "999.999", "990.9999", "0.0001"].each do |percent|
    it { should allow_value(percent).for(attr) }
  end

  ["abc", "&", "-44", "-44.4", "-44.4444"].each do |percent|
    it { should_not allow_value(percent).for(attr) }
  end
end

RSpec.shared_examples_for "comparative percent attribute" do |attr|
  ["1000", "999", "10", "444", "999.999", "999.9999", "0.001", "-1000", "-999", "-10", "-444", "-999.999", "-0.0001"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["abc", "&"].each do |value|
    it { should_not allow_value(value).for(attr) }
  end
end

RSpec.shared_examples_for "age attribute" do |attr|
  ["100", "99", "1 ", "44", "110", "0"].each do |value|
    it { should allow_value(value).for(attr) }
  end


  ["111", "-1", "abc", "&"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.age_format[:numericality][:message]) }
  end
end

RSpec.shared_examples_for "positive dollar attribute" do |attr, normalized: false|
  ["0", "1", "100", "1000", "1000.99"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["-1", "0.2222", "ewrt"].each do |value|
    it { should_not allow_value(value).for(attr) }
  end

  ["1,000,00", "$1,000.00", "1,000,000", "1 000 000.01"].each do |value|
    it { send(normalized ? :should : :should_not, allow_value(value).for(attr)) }
  end
end

RSpec.shared_examples_for "dollar attribute" do |attr, normalized: false|
  ["0", "1", "100", "1000", "1000.99", "-0", "-1", "-100", "-1000", "-1000.99", "12.125", "-12.125"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["0.2222", "ewrt"].each do |value|
    it { should_not allow_value(value).for(attr) }
  end

  [
    "1,000,00", "$1,000.00", "1,000,000", "1 000 000.01",
    "-1,000,00", "-$1,000.00", "-1,000,000", "-1 000 000.01"  # has_normalized_attributes may be used in concert with has_validated_attributes to cover these cases.
  ].each do |value|
    it { send(normalized ? :should : :should_not, allow_value(value).for(attr)) }
  end
end

RSpec.shared_examples_for "number attribute" do |attr, normalized: false|
  ["0", "1", "100", "1000", "-1"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["werq"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.number_format[:numericality][:message]) }
  end

  [
    "1,000,00", "1,000.00", "1,000,000", "1 000 000",  # has_normalized_attributes may be used in concert with has_validated_attributes to cover these cases.
  ].each do |value|
    it { send(normalized ? :should : :should_not, allow_value(value).for(attr).with_message(HasValidatedAttributes.number_format[:numericality][:message])) }
  end
end

RSpec.shared_examples_for "rails name attribute" do |attr|
  ["kc_s", "hey", "yo_", "_jmp", "kc_star_what", "hey", "yo_sucka", "_jump_street"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  [">*", "< test", "test-er", "yo dude"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.rails_name_format[:format][:message].call(nil, attribute: attr.to_s.humanize)) }
  end
end

RSpec.shared_examples_for "taxid attribute" do |attr, normalized: false|
  ["010000000", " ", "545998888"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["ab-cdefgh", "001000000", "abc", "<", "&"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.taxid_format[:numericality][:message]) }
  end

  ["51-5998888", "51 5998858", "44.5559999",].each do |value|
    it { send(normalized ? :should : :should_not, allow_value(value).for(attr).with_message(HasValidatedAttributes.taxid_format[:numericality][:message])) }
  end

  it { send(normalized ? :should : :should_not, allow_value(" 514998888 ").for(attr).with_message(/is the wrong length \(should be 9 characters\)/)) }
end

RSpec.shared_examples_for "ssn attribute" do |attr, normalized: false|
  ["515998488", " "].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["ab-444fgh", "abc", "56599858>", "33445<", "3456356&", "/23452"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(HasValidatedAttributes.social_security_number_format[:numericality][:message]) }
  end

  ["515-99-8888", "544.99 8888", "515 99 8858", "444.33.6666"].each do |value|
    it { send(normalized ? :should : :should_not, allow_value(value).for(attr).with_message(HasValidatedAttributes.social_security_number_format[:numericality][:message])) }
  end

  it { send(normalized ? :should : :should_not, allow_value(" 514998888 ").for(attr).with_message(/is the wrong length \(should be 9 characters\)/)) }
end

RSpec.shared_examples_for "safe text attribute" do |attr|
  [">*", "< test", "Hey\tWorld", "new\nline", "new\r\nline"].each do |value|
    it { should allow_value(value).for(attr) }
  end

  ["\eHey", "Oh\cFNo, it's a control char!"].each do |value|
    it { should_not allow_value(value).for(attr).with_message(/#{HasValidatedAttributes::NO_CONTROL_CHARS_ERROR_MSG}/) }
  end
end
