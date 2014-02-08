# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily do
    network "MyString"
    date "2014-02-04"
    volume 1
    price 1
    amount 1
  end
end
