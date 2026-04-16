# test/factories/units.rb
FactoryBot.define do
  factory :unit do
    block
    # Não definimos floor_number e unit_number manualmente porque o bloco gera as unidades via callback.
    # Em vez disso, podemos criar um bloco e usar sua primeira unidade.
    # Mas se você precisar criar uma unidade diretamente, faça:
    floor_number { 1 }
    unit_number { 1 }
    identifier { "#{block.identifier}-#{floor_number.to_s.rjust(2, '0')}-#{unit_number.to_s.rjust(2, '0')}" }
  end
end