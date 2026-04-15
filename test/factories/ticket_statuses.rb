FactoryBot.define do
  factory :ticket_status do
    sequence(:name) { |n| "Status #{n}" }
    is_default { false }
    is_final { false }

    trait :default do
      is_default { true }
      name { "Aberto" }
    end

    trait :final do
      is_final { true }
      name { "Concluído #{SecureRandom.hex(4)}" } # nome único
    end
  end
end