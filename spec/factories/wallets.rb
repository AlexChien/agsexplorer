# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wallet do
    wallet_id "MyString"
    address "MyText"
    ags_amount 1
  end
end
