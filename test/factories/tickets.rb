FactoryBot.define do
  factory :ticket do
    # Cria um bloco e usa sua primeira unidade (gerada pelo callback)
    unit { create(:block).units.first }
    ticket_type
    ticket_status { TicketStatus.find_by(is_default: true) || create(:ticket_status, :default) }
    description { "Problema descrito pelo morador" }

    user do
      resident = create(:user, :resident)
      # Associa o residente à mesma unidade
      create(:unit_resident, unit: unit, user: resident)
      resident
    end

    trait :closed do
      after(:create) do |ticket|
        ticket.update!(ticket_status: create(:ticket_status, :final))
      end
    end
  end
end