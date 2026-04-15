FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "usuario#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
    role { :resident }

    trait :admin do
      role { :admin }
    end

    trait :collaborator do
      role { :collaborator }
    end
  end
end