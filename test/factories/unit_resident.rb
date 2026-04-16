FactoryBot.define do
  factory :unit_resident do
    unit
    user { association :user, :resident }
  end
end