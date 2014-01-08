# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticker do
    market "MyString"
    pair "MyString"
    last "9.99"
  end
end
