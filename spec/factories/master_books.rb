# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :master_book do
    network "MyString"
    address "MyString"
    donation_amount 1
    ags_amount 1
  end
end
