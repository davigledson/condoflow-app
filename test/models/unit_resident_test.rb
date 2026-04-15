require "test_helper"

class UnitResidentTest < ActiveSupport::TestCase
  setup do
    @resident = create(:user, :resident)
    @unit = create(:block).units.first
  end

  test "é válido com atributos válidos" do
    unit_resident = build(:unit_resident, unit: @unit, user: @resident)
    assert unit_resident.valid?
  end

  test "é inválido sem unit" do
    unit_resident = build(:unit_resident, unit: nil, user: @resident)
    assert_not unit_resident.valid?
    assert_includes unit_resident.errors[:unit], "must exist"
  end

  test "é inválido sem user" do
    unit_resident = build(:unit_resident, unit: @unit, user: nil)
    assert_not unit_resident.valid?
    assert_includes unit_resident.errors[:user], "must exist"
  end

  test "não permite a mesma unidade para o mesmo usuário duas vezes" do
    create(:unit_resident, unit: @unit, user: @resident)
    duplicado = build(:unit_resident, unit: @unit, user: @resident)
    assert_not duplicado.valid?
    assert_includes duplicado.errors[:unit_id], "has already been taken"
  end

  test "permite o mesmo usuário em unidades diferentes" do
    outra_unit = create(:block).units.first
    create(:unit_resident, unit: @unit, user: @resident)
    unit_resident = build(:unit_resident, unit: outra_unit, user: @resident)
    assert unit_resident.valid?
  end

  test "permite a mesma unidade para usuários diferentes" do
    outro_resident = create(:user, :resident, email: "outro@example.com")
    create(:unit_resident, unit: @unit, user: @resident)
    unit_resident = build(:unit_resident, unit: @unit, user: outro_resident)
    assert unit_resident.valid?
  end

  test "não permite usuário não residente (admin)" do
    admin = create(:user, :admin)
    unit_resident = build(:unit_resident, unit: @unit, user: admin)
    assert_not unit_resident.valid?
    assert_includes unit_resident.errors[:user], "deve ter o papel de morador"
  end

  test "não permite usuário não residente (collaborator)" do
    collaborator = create(:user, :collaborator)
    unit_resident = build(:unit_resident, unit: @unit, user: collaborator)
    assert_not unit_resident.valid?
    assert_includes unit_resident.errors[:user], "deve ter o papel de morador"
  end

  test "associação pertence a unit" do
    assoc = UnitResident.reflect_on_association(:unit)
    assert_equal :belongs_to, assoc.macro
  end

  test "associação pertence a user" do
    assoc = UnitResident.reflect_on_association(:user)
    assert_equal :belongs_to, assoc.macro
  end
end