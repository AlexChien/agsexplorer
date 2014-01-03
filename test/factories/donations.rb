# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :donation do
    block_height 1
    time "2014-01-03 14:43:22"
    address "MyString"
    amount 1
    network "MyString"
  end
end
