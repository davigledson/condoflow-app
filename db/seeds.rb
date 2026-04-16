# db/seeds.rb

puts "Limpando banco..."
TicketStatusHistory.delete_all
Comment.delete_all
Ticket.delete_all
CollaboratorTicketType.delete_all
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

admin1 = User.create!(
  name: "Keyllian",
  email: "keyllian@dunnas.com",
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
collaborator1 = User.create!(
  name: "Davi Gledson",
  email: "davi@condominio.com",
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



puts "associando colobarodores a tipos de chamados"
CollaboratorTicketType.create!(user: collaborator, ticket_type: TicketType.find_by(title: "Segurança"))
CollaboratorTicketType.create!(user: collaborator, ticket_type: TicketType.find_by(title: "Limpeza"))

puts "Criando blocos e unidades..."

# O after_create do Block já gera as unidades automaticamente
bloco_a = Block.create!(identifier: "A", floors_count: 3, units_per_floor: 4)
bloco_b = Block.create!(identifier: "B", floors_count: 2, units_per_floor: 3)

puts "Vinculando moradores às unidades..."

puts "Vinculando moradores às unidades..."

# Unidades do bloco A
unidade_a0101 = bloco_a.units.find_by(floor_number: 1, unit_number: 1)
unidade_a0102 = bloco_a.units.find_by(floor_number: 1, unit_number: 2)
unidade_a0201 = bloco_a.units.find_by(floor_number: 2, unit_number: 1)
unidade_a0202 = bloco_a.units.find_by(floor_number: 2, unit_number: 2)
unidade_a0203 = bloco_a.units.find_by(floor_number: 2, unit_number: 3)
unidade_a0204 = bloco_a.units.find_by(floor_number: 2, unit_number: 4)
unidade_a0301 = bloco_a.units.find_by(floor_number: 3, unit_number: 1)
unidade_a0302 = bloco_a.units.find_by(floor_number: 3, unit_number: 2)
unidade_a0103 = bloco_a.units.find_by(floor_number: 1, unit_number: 3)
unidade_a0104 = bloco_a.units.find_by(floor_number: 1, unit_number: 4)

# Unidades do bloco B
unidade_b0101 = bloco_b.units.find_by(floor_number: 1, unit_number: 1)
unidade_b0102 = bloco_b.units.find_by(floor_number: 1, unit_number: 2)
unidade_b0103 = bloco_b.units.find_by(floor_number: 1, unit_number: 3)
unidade_b0201 = bloco_b.units.find_by(floor_number: 2, unit_number: 1)
unidade_b0202 = bloco_b.units.find_by(floor_number: 2, unit_number: 2)
unidade_b0203 = bloco_b.units.find_by(floor_number: 2, unit_number: 3)

# Vincular morador1 (João Silva) às suas unidades (já existentes)
UnitResident.find_or_create_by!(unit: unidade_a0101, user: morador1)
UnitResident.find_or_create_by!(unit: unidade_a0102, user: morador1)

# Vincular morador2 (Maria Souza)
UnitResident.find_or_create_by!(unit: unidade_b0101, user: morador2)

# Vincular outros moradores que aparecem nos tickets
User.find_by(email: "pedro.santos@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0201, user: u) if u
end

User.find_by(email: "ana.oliveira@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0202, user: u) if u
end

User.find_by(email: "lucas.lima@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_b0201, user: u) if u
end

User.find_by(email: "juliana.costa@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0301, user: u) if u
end

User.find_by(email: "rafael.almeida@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0302, user: u) if u
end

User.find_by(email: "patricia.rodrigues@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_b0102, user: u) if u
end

User.find_by(email: "bruno.ferreira@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_b0202, user: u) if u
end

User.find_by(email: "carla.nunes@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0103, user: u) if u
end

User.find_by(email: "thiago.gomes@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0104, user: u) if u
end

User.find_by(email: "larissa.martins@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_b0103, user: u) if u
end

User.find_by(email: "felipe.rocha@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0203, user: u) if u
end

User.find_by(email: "aline.ribeiro@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_a0204, user: u) if u
end

User.find_by(email: "rodrigo.mendes@email.com").tap do |u|
  UnitResident.find_or_create_by!(unit: unidade_b0203, user: u) if u
end

puts "Criando chamados..."
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

ticket3 = Ticket.create!(
  unit: unidade_a0102,
  user: morador1,
  ticket_type: TicketType.find_by(title: "Manutenção Elétrica"),
  description: "Interruptor da sala queimado."
)

ticket4 = Ticket.create!(
  unit: unidade_a0101,
  user: morador1,
  ticket_type: TicketType.find_by(title: "Manutenção Hidráulica"),
  description: "Torneira da cozinha está vazando."
)

ticket5 = Ticket.create!(
  unit: unidade_b0101,
  user: morador2,
  ticket_type: tipo_seguranca,
  description: "Portão da garagem não abre com o controle."
)

ticket6 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 2, unit_number: 1),
  user: User.find_by(email: "pedro.santos@email.com"),
  ticket_type: TicketType.find_by(title: "Limpeza"),
  description: "Lixo acumulado na área da piscina."
)

ticket7 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 2, unit_number: 2),
  user: User.find_by(email: "ana.oliveira@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Elétrica"),
  description: "Lâmpada do corredor do 2º andar queimada."
)

ticket8 = Ticket.create!(
  unit: bloco_b.units.find_by(floor_number: 2, unit_number: 1),
  user: User.find_by(email: "lucas.lima@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Hidráulica"),
  description: "Vazamento no encanamento do banheiro."
)

ticket9 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 3, unit_number: 1),
  user: User.find_by(email: "juliana.costa@email.com"),
  ticket_type: tipo_seguranca,
  description: "Câmera do elevador está com imagem escura."
)

ticket10 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 3, unit_number: 2),
  user: User.find_by(email: "rafael.almeida@email.com"),
  ticket_type: TicketType.find_by(title: "Limpeza"),
  description: "Jardim do térreo precisa de poda urgente."
)

ticket11 = Ticket.create!(
  unit: bloco_b.units.find_by(floor_number: 1, unit_number: 2),
  user: User.find_by(email: "patricia.rodrigues@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Elétrica"),
  description: "Tomada da área de lazer não funciona."
)

ticket12 = Ticket.create!(
  unit: bloco_b.units.find_by(floor_number: 2, unit_number: 2),
  user: User.find_by(email: "bruno.ferreira@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Hidráulica"),
  description: "Ralo da garagem entupido."
)

ticket13 = Ticket.create!(
  unit: unidade_a0102,
  user: morador1,
  ticket_type: tipo_seguranca,
  description: "Sensor do portão automático está desregulado."
)

ticket14 = Ticket.create!(
  unit: unidade_b0101,
  user: morador2,
  ticket_type: TicketType.find_by(title: "Limpeza"),
  description: "Piso da escada de emergência escorregadio."
)

ticket15 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 1, unit_number: 3),
  user: User.find_by(email: "carla.nunes@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Elétrica"),
  description: "Disjuntor da cozinha desarma sozinho."
)

ticket16 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 1, unit_number: 4),
  user: User.find_by(email: "thiago.gomes@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Hidráulica"),
  description: "Mau cheiro vindo do ralo do banheiro."
)

ticket17 = Ticket.create!(
  unit: bloco_b.units.find_by(floor_number: 1, unit_number: 3),
  user: User.find_by(email: "larissa.martins@email.com"),
  ticket_type: tipo_seguranca,
  description: "Botão de emergência do elevador não funciona."
)

ticket18 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 2, unit_number: 3),
  user: User.find_by(email: "felipe.rocha@email.com"),
  ticket_type: TicketType.find_by(title: "Limpeza"),
  description: "Parede do corredor pichada."
)

ticket19 = Ticket.create!(
  unit: bloco_a.units.find_by(floor_number: 2, unit_number: 4),
  user: User.find_by(email: "aline.ribeiro@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Elétrica"),
  description: "Internet com queda frequente."
)

ticket20 = Ticket.create!(
  unit: bloco_b.units.find_by(floor_number: 2, unit_number: 3),
  user: User.find_by(email: "rodrigo.mendes@email.com"),
  ticket_type: TicketType.find_by(title: "Manutenção Hidráulica"),
  description: "Válvula de descarga da área comum quebrada."
)

puts "Adicionando comentários..."

Comment.create!(ticket: ticket1, user: morador1, body: "Já faz 3 dias com esse problema.")
Comment.create!(ticket: ticket1, user: collaborator, body: "Estamos verificando, obrigado.")
Comment.create!(ticket: ticket2, user: morador2, body: "Situação piorou hoje.")
Comment.create!(ticket: ticket3, user: morador1, body: "Não consigo ligar a luz da sala.")
Comment.create!(ticket: ticket4, user: collaborator, body: "Vamos enviar um técnico amanhã.")
Comment.create!(ticket: ticket6, user: User.find_by(email: "pedro.santos@email.com"), body: "O lixo está atraindo ratos!")
Comment.create!(ticket: ticket8, user: User.find_by(email: "lucas.lima@email.com"), body: "Já é o segundo vazamento este mês.")
Comment.create!(ticket: ticket10, user: collaborator, body: "Equipe de jardinagem avisada.")
Comment.create!(ticket: ticket12, user: admin, body: "Vamos verificar com urgência.")
Comment.create!(ticket: ticket15, user: User.find_by(email: "carla.nunes@email.com"), body: "Desarmou três vezes hoje.")
Comment.create!(ticket: ticket17, user: collaborator, body: "Elevador será inspecionado.")
Comment.create!(ticket: ticket19, user: User.find_by(email: "aline.ribeiro@email.com"), body: "Perco a conexão toda hora.")

puts "Registrando mudanças de status..."

ticket1.update!(ticket_status: TicketStatus.find_by(name: "Em andamento"))
TicketStatusHistory.create!(
  ticket: ticket1,
  ticket_status: TicketStatus.find_by(name: "Em andamento"),
  user: collaborator
)

ticket3.update!(ticket_status: TicketStatus.find_by(name: "Concluído"))
TicketStatusHistory.create!(
  ticket: ticket3,
  ticket_status: TicketStatus.find_by(name: "Concluído"),
  user: admin
)

ticket5.update!(ticket_status: TicketStatus.find_by(name: "Cancelado"))
TicketStatusHistory.create!(
  ticket: ticket5,
  ticket_status: TicketStatus.find_by(name: "Cancelado"),
  user: morador2
)

ticket8.update!(ticket_status: TicketStatus.find_by(name: "Em andamento"))
TicketStatusHistory.create!(
  ticket: ticket8,
  ticket_status: TicketStatus.find_by(name: "Em andamento"),
  user: collaborator
)

ticket12.update!(ticket_status: TicketStatus.find_by(name: "Concluído"))
TicketStatusHistory.create!(
  ticket: ticket12,
  ticket_status: TicketStatus.find_by(name: "Concluído"),
  user: admin
)

ticket16.update!(ticket_status: TicketStatus.find_by(name: "Cancelado"))
TicketStatusHistory.create!(
  ticket: ticket16,
  ticket_status: TicketStatus.find_by(name: "Cancelado"),
  user: collaborator
)

puts "\nPronto! Credenciais:"
puts "  admin:        admin@condominio.com       / 123456"
puts "  collaborator: colaborador@condominio.com / 123456"
puts "  morador 1:    joao@email.com             / 123456"
puts "  morador 2:    maria@email.com            / 123456"

