FactoryBot.define do
  factory :block do
    # Usa sequence para gerar identificadores únicos automaticamente
    sequence(:identifier) { |n| "Bloco-#{n}" }
    floors_count { 2 }
    units_per_floor { 3 }
  end
end