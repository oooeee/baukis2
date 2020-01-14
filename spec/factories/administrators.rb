FactoryBot.define do
  factory :administrator do
    sequence(:email) {|n| "admin#{n}@example.com"}
    password {"hoge"}
    suspended {false}
  end
end