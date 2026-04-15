# test/factories/comments.rb
FactoryBot.define do
  factory :comment do
    ticket
    user
    body { "Comentário padrão" }
  end
end