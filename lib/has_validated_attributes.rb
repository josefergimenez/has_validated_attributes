# encoding: utf-8
# frozen_string_literal: true


require "active_record"

module HasValidatedAttributes
  extend ActiveSupport::Concern
  NO_CONTROL_CHARS_REGEX = /\A[^[:cntrl:]]*\z/
  NO_CONTROL_CHARS_ERROR_MSG = "avoid non-printing characters"

  # instance methods
  def self.validations(*args)
    args.first.each do |name, format|
      # show attribute name to error message
      if (message = format.dig(:format, :message)).present?
        format[:format][:message] = -> (_, data) { "#{message} for #{data[:attribute]}" }
      end

      HasValidatedAttributes.define_singleton_method "#{name}_format" do |field_name = nil, options = {}|
        validation = {}
        validation[:if] = "#{field_name}?".to_sym if format.delete(:has_if?)
        # length options
        if (opts = options.select { |k, _v| k.match(/length/) }).present?
          opts.each do |k, v|
            if k == :precision_length
              format[:format][:with] = Regexp.new "\\A-?[0-9]{0,12}(\.[0-9]{0,#{options[:precision_length]}})?\\z"
            else
              validation[:length] = { k.to_s.split("_").first.to_sym => v }
            end
            options.delete(k)
          end
        end

        # extra options
        validation.merge!(options) if options.present?

        format.merge(validation)
      end
    end
  end

  class SafeTextValidator < ::ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, "#{NO_CONTROL_CHARS_ERROR_MSG} for #{attribute}") unless NO_CONTROL_CHARS_REGEX =~ value.to_s.gsub(/[\n\r\t]/, "")
    end
  end

  # loading all methods dynamically
  validations name: { format: { with: NO_CONTROL_CHARS_REGEX, message: NO_CONTROL_CHARS_ERROR_MSG }, length: { maximum: 63 }, has_if?: true },
              safe_text: { safe_text: true, has_if?: true },
              username: { length: { within: 5..127 }, format: { with: /\A\w[\w\.\-_@]+\z/, message: "use only letters, numbers, and .-_@ please" }, uniqueness: true, has_if?: true },
              rails_name: { format: { with: /\A[a-zA-Z\_]*?\z/u, message: "should only include underscores and letters" } },
              ## the regex for emails comes from
              ##   http://haacked.com/archive/2007/08/21/i-knew-how-to-validate-an-email-address-until-i.aspx/
              email: { length: { maximum: 63 }, format: { with: /\A(?!\.)("([^"\r\\]|\\["\r\\])*"|([-a-z0-9!#$%&'’*+\/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-z0-9][\w\.-]*[a-z0-9]*\.[a-z][a-z\.]*[a-z]\z/i, message: "should look like an email address" }, has_if?: true },
              phone_number: { numericality: { greater_than_or_equal_to: 1000000000, less_than: 10000000000, message: "accepts only 10 numbers and (),.- characters and must not be all 0s" }, has_if?: true },
              phone_extension: { length: { maximum: 7 }, format: { with: /\A\d+([\dxX]*\d)?\z/, message: 'accepts only numbers (0-9) and "x"' }, has_if?: true },
              domain: { length: { maximum: 63 }, format: { with: /[a-z0-9-]+\.[a-z0-9\-\/\.]+/, message: "should look like a domain name" }, has_if?: true },
              zipcode: { format: { with: /\A\d{5}(\d{4})?\z/, message: "must contain 5 or 9 numbers" }, has_if?: true },
              middle_initial: { format: { with: /\A[a-zA-Z]{0,1}\z/u, message: "accepts only one letter" } },
              dollar: { format: { with: /\A-?[0-9]{0,12}(\.[0-9]{0,2})?\z/, message: "accepts only numeric characters, period, and negative sign" }, numericality: { greater_than: -1000000000000, less_than: 1000000000000 }, allow_nil: true },
              positive_dollar: { format: { with: /\A[0-9]{0,12}(\.[0-9]{0,2})?\z/, message: "accepts only numeric characters, period" }, numericality: { greater_than_or_equal_to: 0, less_than: 1000000000000 }, allow_nil: true },
              percent: { format: { with: /\A-?[0-9]{0,4}(\.[0-9]{0,4})?\z/, message: "accepts only numeric characters, period, negative sign, and must be equal/less/greater than +/- 100" }, numericality: { greater_than_or_equal_to: -100, less_than_or_equal_to: 100 }, has_if?: true },
              positive_percent: { format: { with: /\A[0-9]{0,4}(\.[0-9]{0,4})?\z/, message: "accepts only numeric characters, period, and must be equal/less than 100" }, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true },
              comparative_percent: { format: { with: /\A-?[0-9]{0,4}(\.[0-9]{0,4})?\z/, message: "accepts only numeric characters, period and a negative sign" }, has_if?: true },
              positive_comparative_percent: { format: { with: /\A[0-9]{0,4}(\.[0-9]{0,4})?\z/, message: "accepts only numeric characters and a period" }, allow_nil: true },
              url: { length: { maximum: 255 }, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "web address isnt valid" }, has_if?: true },
              social_security_number: { length: { is: 9 }, numericality: { greater_than_or_equal_to: 0, less_than: 1000000000, message: "must be in the format 111-11-1111" }, has_if?: true },
              taxid: { length: { is: 9 }, numericality: { greater_than_or_equal_to: 9999999, less_than: 1000000000, message: "must be in the format 11-1111111" }, has_if?: true },
              age: { numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 110, message: "must contain only 3 numbers and less than 110" }, has_if?: true },
              number: { numericality: { message: "accepts only numbers (0-9)" }, has_if?: true }

  included do
    class_eval do
      def self.has_validated_attributes(args = {})
        if args.blank? || !args.is_a?(Hash)
          raise ArgumentError, "Must define the fields you want to be validate with has_validated_attributes :field_one => {:format => :phone}, :field_two => {:format => :zipcode, :required => true}"
        end

        args.each do |field, options|
          type = options.delete(:format)
          validates field.to_sym, HasValidatedAttributes.send("#{type}_format".to_sym, field, options)
        end
      end
    end
  end
end

# include activerecord
ActiveRecord::Base.include HasValidatedAttributes
