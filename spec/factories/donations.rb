# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :donation do
    block_height 1
    time Time.now.utc
    address "MyString"
    amount 1
    network "btc"
  end
end
