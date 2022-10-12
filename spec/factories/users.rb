FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true, special_characters: true) }
  end
end
