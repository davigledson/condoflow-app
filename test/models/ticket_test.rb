require "test_helper"

class TicketTest < ActiveSupport::TestCase
  setup do
    # Garante um status padrão (único) para todos os testes
    @default_status = TicketStatus.find_or_create_by(is_default: true) do |s|
      s.name = "Aberto"
      s.is_final = false
    end
  end

  test "é válido com atributos válidos" do
    ticket = build(:ticket)
    assert ticket.valid?
  end

  test "é inválido sem description" do
    ticket = build(:ticket, description: nil)
    assert_not ticket.valid?
    assert_includes ticket.errors[:description], "can't be blank"
  end

  test "define status padrão na criação se não fornecido" do
    ticket = create(:ticket, ticket_status: nil)
    assert_equal @default_status, ticket.ticket_status
  end

  test "não sobrescreve status fornecido na criação" do
    # Cria um status NÃO padrão (is_default: false) com nome único
    outro_status = create(:ticket_status, is_default: false, name: "Outro Status #{SecureRandom.hex(4)}")
    ticket = create(:ticket, ticket_status: outro_status)
    assert_equal outro_status, ticket.ticket_status
  end

  test "morador deve pertencer à unidade do chamado" do
    resident = create(:user, :resident)
    outra_unidade = create(:block).units.first
    ticket = build(:ticket, user: resident, unit: outra_unidade)
    assert_not ticket.valid?
    assert_includes ticket.errors[:user], "não pertence a essa unidade"
  end

  test "morador vinculado à unidade é válido" do
    resident = create(:user, :resident)
    unit = create(:block).units.first
    create(:unit_resident, unit: unit, user: resident)
    ticket = build(:ticket, user: resident, unit: unit)
    assert ticket.valid?
  end

  test "quando ticket_status muda para final, closed_at é preenchido" do
    ticket = create(:ticket)
    assert_nil ticket.closed_at

    # Cria um status final com nome único e is_final: true, is_default: false
    final_status = create(:ticket_status, is_final: true, is_default: false, name: "Final #{SecureRandom.hex(4)}")
    ticket.update!(ticket_status: final_status)
    assert_not_nil ticket.closed_at
    assert_in_delta Time.current, ticket.closed_at, 1.second
  end

  test "quando ticket_status muda de final para não final, closed_at volta a nil" do
    final_status = create(:ticket_status, is_final: true, is_default: false, name: "Final #{SecureRandom.hex(4)}")
    ticket = create(:ticket, ticket_status: final_status)
    assert_not_nil ticket.closed_at

    # Usa o status padrão já existente (não cria outro)
    ticket.update!(ticket_status: @default_status)
    assert_nil ticket.closed_at
  end

  
end