require "test_helper"

class TicketTypeTest < ActiveSupport::TestCase
  test "é válido com atributos válidos" do
    ticket_type = build(:ticket_type)
    assert ticket_type.valid?
  end

  test "é inválido sem title" do
    ticket_type = build(:ticket_type, title: nil)
    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:title], "can't be blank"
  end

  test "é inválido com title duplicado" do
    create(:ticket_type, title: "Elétrica")
    duplicado = build(:ticket_type, title: "Elétrica")
    assert_not duplicado.valid?
    assert_includes duplicado.errors[:title], "has already been taken"
  end

  test "é inválido sem sla_hours" do
    ticket_type = build(:ticket_type, sla_hours: nil)
    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:sla_hours], "can't be blank"
  end

  test "sla_hours deve ser maior que zero" do
    ticket_type = build(:ticket_type, sla_hours: 0)
    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:sla_hours], "must be greater than 0"

    ticket_type = build(:ticket_type, sla_hours: -1)
    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:sla_hours], "must be greater than 0"
  end

  # Associações
  test "tem muitos tickets" do
    assoc = TicketType.reflect_on_association(:tickets)
    assert_equal :has_many, assoc.macro
  end

  test "tem muitos collaborator_ticket_types" do
    assoc = TicketType.reflect_on_association(:collaborator_ticket_types)
    assert_equal :has_many, assoc.macro
    assert_equal :destroy, assoc.options[:dependent]
  end

  test "tem muitos colaboradores através de collaborator_ticket_types" do
    assoc = TicketType.reflect_on_association(:collaborators)
    assert_equal :has_many, assoc.macro
    assert_equal :collaborator_ticket_types, assoc.options[:through]
    assert_equal :user, assoc.options[:source]
  end
end