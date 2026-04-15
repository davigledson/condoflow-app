require "test_helper"

class TicketStatusTest < ActiveSupport::TestCase
  setup do
    # Remove qualquer status padrão residual de outros testes
    TicketStatus.where(is_default: true).destroy_all
  end

  test "é válido com atributos válidos" do
    status = build(:ticket_status, name: "Novo Status")
    assert status.valid?
  end

  test "é inválido sem name" do
    status = build(:ticket_status, name: nil)
    assert_not status.valid?
    assert_includes status.errors[:name], "can't be blank"
  end

  test "é inválido com name duplicado" do
    create(:ticket_status, name: "Duplicado")
    status = build(:ticket_status, name: "Duplicado")
    assert_not status.valid?
    assert_includes status.errors[:name], "has already been taken"
  end

  test "é inválido se is_default não for booleano (nil)" do
    status = build(:ticket_status, is_default: nil)
    assert_not status.valid?
    assert_includes status.errors[:is_default], "is not included in the list"
  end

  test "é inválido se is_final não for booleano (nil)" do
    status = build(:ticket_status, is_final: nil)
    assert_not status.valid?
    assert_includes status.errors[:is_final], "is not included in the list"
  end

  test "permite apenas um status padrão" do
    default1 = create(:ticket_status, name: "Padrão Único", is_default: true)
    assert default1.valid?

    default2 = build(:ticket_status, name: "Outro Padrão", is_default: true)
    assert_not default2.valid?
    assert_includes default2.errors[:is_default], "já existe um status padrão"
  end

  test "pode alterar o status padrão (editar um existente)" do
    default = create(:ticket_status, name: "Original", is_default: true)
    # Atualiza o mesmo registro (deve permanecer válido)
    default.name = "Original Modificado"
    assert default.valid?, "Não pode editar o status padrão existente"
  end

  test "pode reatribuir o status padrão para outro status" do
    status1 = create(:ticket_status, name: "Status 1", is_default: true)
    status2 = create(:ticket_status, name: "Status 2", is_default: false)

    # Troca o padrão para status2
    status1.update!(is_default: false)
    status2.update!(is_default: true)

    assert status2.valid?
    assert status1.valid?
    assert_equal false, status1.is_default
    assert_equal true, status2.is_default
  end

  test "permite múltiplos status com is_default false" do
    create(:ticket_status, name: "Status A", is_default: false)
    status2 = build(:ticket_status, name: "Status B", is_default: false)
    assert status2.valid?
  end

  test "associação tem muitos tickets" do
    assoc = TicketStatus.reflect_on_association(:tickets)
    assert_equal :has_many, assoc.macro
  end

  test "associação tem muitos ticket_status_histories" do
    assoc = TicketStatus.reflect_on_association(:ticket_status_histories)
    assert_equal :has_many, assoc.macro
  end
end