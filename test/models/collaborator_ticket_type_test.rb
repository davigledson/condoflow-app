# test/models/collaborator_ticket_type_test.rb
require "test_helper"

class CollaboratorTicketTypeTest < ActiveSupport::TestCase
  setup do
    @collaborator = create(:user, :collaborator)
    @ticket_type = create(:ticket_type)
  end

  test "é válido com atributos válidos" do
    ctt = build(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
    assert ctt.valid?
  end

  test "é inválido sem user" do
    ctt = build(:collaborator_ticket_type, user: nil, ticket_type: @ticket_type)
    assert_not ctt.valid?
    assert_includes ctt.errors[:user], "must exist"
  end

  test "é inválido sem ticket_type" do
    ctt = build(:collaborator_ticket_type, user: @collaborator, ticket_type: nil)
    assert_not ctt.valid?
    assert_includes ctt.errors[:ticket_type], "must exist"
  end

  test "não permite o mesmo ticket_type para o mesmo usuário" do
    create(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
    duplicado = build(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
    assert_not duplicado.valid?
    assert_includes duplicado.errors[:ticket_type_id], "has already been taken"
  end

  test "permite mesmo ticket_type para usuários diferentes" do
    outro_collaborator = create(:user, :collaborator, email: "outro@exemplo.com")
    create(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
    ctt = build(:collaborator_ticket_type, user: outro_collaborator, ticket_type: @ticket_type)
    assert ctt.valid?
  end

  test "não permite admin" do
    admin = create(:user, :admin)
    ctt = build(:collaborator_ticket_type, user: admin, ticket_type: @ticket_type)
    assert_not ctt.valid?
    assert_includes ctt.errors[:user], "deve ser um colaborador"
  end

  test "não permite resident" do
    resident = create(:user, :resident)
    ctt = build(:collaborator_ticket_type, user: resident, ticket_type: @ticket_type)
    assert_not ctt.valid?
    assert_includes ctt.errors[:user], "deve ser um colaborador"
  end
end