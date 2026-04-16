require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    # Cria blocos e unidades manualmente (com identificadores únicos)
    @block = Block.create!(identifier: "X", floors_count: 1, units_per_floor: 1)
    @unit = @block.units.first

    # Cria tipos de chamado e status
    @ticket_type = TicketType.create!(title: "Teste", sla_hours: 24)
    @ticket_status = TicketStatus.create!(name: "Aberto", is_default: true, is_final: false)

    # Cria usuários
    @resident = User.create!(name: "Residente", email: "resident@test.com", password: "123456", password_confirmation: "123456", role: :resident)
    @admin = User.create!(name: "Admin", email: "admin@test.com", password: "123456", password_confirmation: "123456", role: :admin)
    @collaborator = User.create!(name: "Colaborador", email: "collab@test.com", password: "123456", password_confirmation: "123456", role: :collaborator)

    # Vincula o residente à unidade
    UnitResident.create!(unit: @unit, user: @resident)

    # Cria o ticket associado ao residente e à unidade
    @ticket = Ticket.create!(
      unit: @unit,
      user: @resident,
      ticket_type: @ticket_type,
      ticket_status: @ticket_status,
      description: "Problema de teste"
    )
  end

  test "é válido com atributos válidos (morador com permissão)" do
    comment = Comment.new(ticket: @ticket, user: @resident, body: "Comentário válido")
    assert comment.valid?
  end

  test "é inválido sem body" do
    comment = Comment.new(ticket: @ticket, user: @resident, body: nil)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "morador pode comentar apenas em chamados das suas unidades" do
    comment = Comment.new(ticket: @ticket, user: @resident, body: "Ok")
    assert comment.valid?

    # Cria outro bloco, unidade e residente (sem vínculo com @resident)
    outro_block = Block.create!(identifier: "Y", floors_count: 1, units_per_floor: 1)
    outra_unit = outro_block.units.first
    outro_resident = User.create!(name: "Outro", email: "outro@test.com", password: "123456", password_confirmation: "123456", role: :resident)
    UnitResident.create!(unit: outra_unit, user: outro_resident)
    outro_ticket = Ticket.create!(
      unit: outra_unit,
      user: outro_resident,
      ticket_type: @ticket_type,
      ticket_status: @ticket_status,
      description: "Outro problema"
    )

    comment2 = Comment.new(ticket: outro_ticket, user: @resident, body: "Sem permissão")
    assert_not comment2.valid?
    assert_includes comment2.errors[:user], "não tem permissão para comentar neste chamado"
  end

  test "admin pode comentar em qualquer chamado" do
    comment = Comment.new(ticket: @ticket, user: @admin, body: "Admin comentando")
    assert comment.valid?

    outro_ticket = Ticket.create!(
      unit: @unit,
      user: @resident,
      ticket_type: @ticket_type,
      ticket_status: @ticket_status,
      description: "Outro chamado"
    )
    comment2 = Comment.new(ticket: outro_ticket, user: @admin, body: "Outro admin")
    assert comment2.valid?
  end

  test "collaborator pode comentar em qualquer chamado" do
    comment = Comment.new(ticket: @ticket, user: @collaborator, body: "Colaborador comentando")
    assert comment.valid?

    outro_ticket = Ticket.create!(
      unit: @unit,
      user: @resident,
      ticket_type: @ticket_type,
      ticket_status: @ticket_status,
      description: "Outro chamado"
    )
    comment2 = Comment.new(ticket: outro_ticket, user: @collaborator, body: "Outro colaborador")
    assert comment2.valid?
  end

  test "pertence a ticket" do
    assoc = Comment.reflect_on_association(:ticket)
    assert_equal :belongs_to, assoc.macro
  end

  test "pertence a user" do
    assoc = Comment.reflect_on_association(:user)
    assert_equal :belongs_to, assoc.macro
  end

  test "tem muitos anexos (has_many_attached)" do
    comment = Comment.new(ticket: @ticket, user: @resident, body: "Anexos")
    assert_respond_to comment, :attachments
  end
end