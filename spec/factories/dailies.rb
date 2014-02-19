# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily do
    network "btc"
    date "2014-02-04"
    price 1
    amount 1
  end
end
