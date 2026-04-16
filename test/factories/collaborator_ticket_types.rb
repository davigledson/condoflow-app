FactoryBot.define do
  factory :collaborator_ticket_type do
    user { association :user, :collaborator }
    ticket_type
  end
end