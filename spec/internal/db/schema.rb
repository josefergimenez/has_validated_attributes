# frozen_string_literal: true

ActiveRecord::Schema.define do
  # Set up any tables you need to exist for your test suite that don't belong
  # in migrations.
  create_table "resources", :force => true do |t|
    t.string   "username_attr"
    t.string   "name_attr"
    t.string   "safe_text_attr"
    t.string   "domain_attr"
    t.string   "email_attr"
    t.string   "phone_number_attr"
    t.string   "phone_extension_attr"
    t.string   "middle_initial_attr"
    t.string   "ssn_attr"
    t.string   "zipcode_attr"
    t.string   "taxid_attr"
    t.string   "dollar_attr"
    t.string   "positive_dollar_attr"
    t.string   "percent_attr"
    t.string   "positive_percent_attr"
    t.string   "comparative_percent_attr"
    t.string   "positive_comparative_percent_attr"
    t.string   "url_attr"
    t.string   "age_attr"
    t.string   "number_attr"
    t.string   "rails_name_attr"
  end
end
