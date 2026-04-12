# db/seeds.rb

puts "Limpando banco..."
TicketStatusHistory.delete_all
Comment.delete_all
Ticket.delete_all
UnitResident.delete_all
Unit.delete_all
Block.delete_all
TicketType.delete_all
TicketStatus.delete_all
User.delete_all

puts "Criando usuários..."

admin = User.create!(
  name: "Administrador",
  email: "admin@condominio.com",
  password: "123456",
  password_confirmation: "123456",
  role: :admin
)

collaborator = User.create!(
  name: "Colaborador",
  email: "colaborador@condominio.com",
  password: "123456",
  password_confirmation: "123456",
  role: :collaborator
)

morador1 = User.create!(
  name: "João Silva",
  email: "joao@email.com",
  password: "123456",
  password_confirmation: "123456",
  role: :resident
)

morador2 = User.create!(
  name: "Maria Souza",
  email: "maria@email.com",
  password: "123456",
  password_confirmation: "123456",
  role: :resident
)

# Moradores (residentes) - aproximadamente 27 para chegar a 30 no total
moradores = [
  { name: "João Silva", email: "joao.silva@email.com" },
  { name: "Maria Souza", email: "maria.souza@email.com" },
  { name: "Pedro Santos", email: "pedro.santos@email.com" },
  { name: "Ana Paula Oliveira", email: "ana.oliveira@email.com" },
  { name: "Lucas Lima", email: "lucas.lima@email.com" },
  { name: "Juliana Costa", email: "juliana.costa@email.com" },
  { name: "Rafael Almeida", email: "rafael.almeida@email.com" },
  { name: "Patrícia Rodrigues", email: "patricia.rodrigues@email.com" },
  { name: "Bruno Ferreira", email: "bruno.ferreira@email.com" },
  { name: "Carla Nunes", email: "carla.nunes@email.com" },
  { name: "Thiago Gomes", email: "thiago.gomes@email.com" },
  { name: "Larissa Martins", email: "larissa.martins@email.com" },
  { name: "Felipe Rocha", email: "felipe.rocha@email.com" },
  { name: "Aline Ribeiro", email: "aline.ribeiro@email.com" },
  { name: "Rodrigo Mendes", email: "rodrigo.mendes@email.com" },
  { name: "Camila Cardoso", email: "camila.cardoso@email.com" },
  { name: "Marcos Paulo", email: "marcos.paulo@email.com" },
  { name: "Vanessa Dias", email: "vanessa.dias@email.com" },
  { name: "Diego Barbosa", email: "diego.barbosa@email.com" },
  { name: "Renata Castro", email: "renata.castro@email.com" },
  { name: "Gustavo Moreira", email: "gustavo.moreira@email.com" },
  { name: "Tatiana Azevedo", email: "tatiana.azevedo@email.com" },
  { name: "Eduardo Pires", email: "eduardo.pires@email.com" },
  { name: "Simone Lopes", email: "simone.lopes@email.com" },
  { name: "André Carvalho", email: "andre.carvalho@email.com" },
  { name: "Michele Souza", email: "michele.souza@email.com" },
  { name: "Leandro Nogueira", email: "leandro.nogueira@email.com" }
]

moradores.each do |m|
  User.create!(
    name: m[:name],
    email: m[:email],
    password: "123456",
    password_confirmation: "123456",
    role: :resident
  )
end

puts "Criando status de chamado..."

status_aberto = TicketStatus.create!(
  name: "Aberto",
  is_default: true,
  is_final: false
)

TicketStatus.create!(
  name: "Em andamento",
  is_default: false,
  is_final: false
)

status_concluido = TicketStatus.create!(
  name: "Concluído",
  is_default: false,
  is_final: true
)

TicketStatus.create!(
  name: "Cancelado",
  is_default: false,
  is_final: true
)

puts "Criando tipos de chamado..."

TicketType.create!(title: "Manutenção Elétrica", sla_hours: 24)
TicketType.create!(title: "Manutenção Hidráulica", sla_hours: 48)
TicketType.create!(title: "Limpeza", sla_hours: 12)
tipo_seguranca = TicketType.create!(title: "Segurança", sla_hours: 2)

puts "Criando blocos e unidades..."

# O after_create do Block já gera as unidades automaticamente
bloco_a = Block.create!(identifier: "A", floors_count: 3, units_per_floor: 4)
bloco_b = Block.create!(identifier: "B", floors_count: 2, units_per_floor: 3)

puts "Vinculando moradores às unidades..."

unidade_a0101 = bloco_a.units.find_by(floor_number: 1, unit_number: 1)
unidade_a0102 = bloco_a.units.find_by(floor_number: 1, unit_number: 2)
unidade_b0101 = bloco_b.units.find_by(floor_number: 1, unit_number: 1)

UnitResident.create!(unit: unidade_a0101, user: morador1)
UnitResident.create!(unit: unidade_a0102, user: morador1)  # joao tem 2 unidades
UnitResident.create!(unit: unidade_b0101, user: morador2)

puts "Criando chamados..."

ticket1 = Ticket.create!(
  unit: unidade_a0101,
  user: morador1,
  ticket_type: tipo_seguranca,
  description: "Câmera do hall de entrada com defeito."
)

ticket2 = Ticket.create!(
  unit: unidade_b0101,
  user: morador2,
  ticket_type: TicketType.find_by(title: "Limpeza"),
  description: "Corredor do 1º andar precisa de limpeza urgente."
)

puts "Adicionando comentários..."

Comment.create!(ticket: ticket1, user: morador1, body: "Já faz 3 dias com esse problema.")
Comment.create!(ticket: ticket1, user: collaborator, body: "Estamos verificando, obrigado.")
Comment.create!(ticket: ticket2, user: morador2, body: "Situação piorou hoje.")

puts "Registrando mudança de status..."

ticket1.update!(ticket_status: TicketStatus.find_by(name: "Em andamento"))
TicketStatusHistory.create!(
  ticket: ticket1,
  ticket_status: TicketStatus.find_by(name: "Em andamento"),
  user: collaborator
)

puts "\nPronto! Credenciais:"
puts "  admin:        admin@condominio.com       / 123456"
puts "  collaborator: colaborador@condominio.com / 123456"
puts "  morador 1:    joao@email.com             / 123456"
puts "  morador 2:    maria@email.com            / 123456"