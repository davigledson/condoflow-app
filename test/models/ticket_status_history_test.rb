require "test_helper"

class TicketStatusHistoryTest < ActiveSupport::TestCase
  setup do
    # Cria uma unidade, bloco, tipo de chamado, status padrão, etc.
    @block = Block.create!(identifier: "Z", floors_count: 1, units_per_floor: 1)
    @unit = @block.units.first

    @ticket_type = TicketType.create!(title: "Teste", sla_hours: 24)
    @ticket_status = TicketStatus.create!(name: "Aberto", is_default: true, is_final: false)
    @outro_status = TicketStatus.create!(name: "Em andamento", is_default: false, is_final: false)

    @user = User.create!(name: "Usuário", email: "user@test.com", password: "123456", password_confirmation: "123456", role: :collaborator)
    @resident = User.create!(name: "Residente", email: "resident@test.com", password: "123456", password_confirmation: "123456", role: :resident)
    UnitResident.create!(unit: @unit, user: @resident)

    @ticket = Ticket.create!(
      unit: @unit,
      user: @resident,
      ticket_type: @ticket_type,
      ticket_status: @ticket_status,
      description: "Problema"
    )
  end

  test "é válido com todos os atributos" do
    history = TicketStatusHistory.new(
      ticket: @ticket,
      ticket_status: @outro_status,
      user: @user
    )
    assert history.valid?
  end

  test "é inválido sem ticket" do
    history = TicketStatusHistory.new(
      ticket: nil,
      ticket_status: @outro_status,
      user: @user
    )
    assert_not history.valid?
    assert_includes history.errors[:ticket], "must exist"
  end

  test "é inválido sem ticket_status" do
    history = TicketStatusHistory.new(
      ticket: @ticket,
      ticket_status: nil,
      user: @user
    )
    assert_not history.valid?
    assert_includes history.errors[:ticket_status], "must exist"
  end

  test "é inválido sem user" do
    history = TicketStatusHistory.new(
      ticket: @ticket,
      ticket_status: @outro_status,
      user: nil
    )
    assert_not history.valid?
    assert_includes history.errors[:user], "must exist"
  end

  test "pertence a ticket" do
    assoc = TicketStatusHistory.reflect_on_association(:ticket)
    assert_equal :belongs_to, assoc.macro
  end

  test "pertence a ticket_status" do
    assoc = TicketStatusHistory.reflect_on_association(:ticket_status)
    assert_equal :belongs_to, assoc.macro
  end

  test "pertence a user" do
    assoc = TicketStatusHistory.reflect_on_association(:user)
    assert_equal :belongs_to, assoc.macro
  end
end