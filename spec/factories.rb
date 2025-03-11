FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Имя#{n}" }
    sequence(:patronymic) { |n| "Отчество#{n}" }
    sequence(:surname) { |n| "Фамилия#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
    age { 30 }
    nationality { "Русский" }
    country { "Россия" }
    gender { "male" }
  end

  factory :interest do
    sequence(:name) { |n| "Интерес#{n}" }
  end

  factory :skill do
    sequence(:name) { |n| "Навык#{n}" }
  end
end