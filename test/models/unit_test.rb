require "test_helper"

class UnitTest < ActiveSupport::TestCase
  setup do
    @block = create(:block, identifier: "A", floors_count: 2, units_per_floor: 2)
    @unit = @block.units.first
  end

  test "é válido com atributos válidos" do
    assert @unit.valid?
  end

  test "é inválido sem floor_number" do
    @unit.floor_number = nil
    assert_not @unit.valid?
    assert_includes @unit.errors[:floor_number], "can't be blank"
  end

  test "floor_number deve ser maior que zero" do
    @unit.floor_number = 0
    assert_not @unit.valid?
    assert_includes @unit.errors[:floor_number], "must be greater than 0"

    @unit.floor_number = -1
    assert_not @unit.valid?
    assert_includes @unit.errors[:floor_number], "must be greater than 0"
  end

  test "é inválido sem unit_number" do
    @unit.unit_number = nil
    assert_not @unit.valid?
    assert_includes @unit.errors[:unit_number], "can't be blank"
  end

  test "unit_number deve ser maior que zero" do
    @unit.unit_number = 0
    assert_not @unit.valid?
    assert_includes @unit.errors[:unit_number], "must be greater than 0"

    @unit.unit_number = -1
    assert_not @unit.valid?
    assert_includes @unit.errors[:unit_number], "must be greater than 0"
  end

  test "é inválido sem identifier" do
    @unit.identifier = nil
    assert_not @unit.valid?
    assert_includes @unit.errors[:identifier], "can't be blank"
  end

  test "não permite unit_number duplicado no mesmo bloco e andar" do
    # O bloco já criou unidades: (1,1), (1,2), (2,1), (2,2)
    duplicada = Unit.new(
      block: @block,
      floor_number: 1,
      unit_number: 1,
      identifier: "duplicada"
    )
    assert_not duplicada.valid?
    assert_includes duplicada.errors[:unit_number], "has already been taken"
  end

  test "permite unit_number duplicado em blocos diferentes" do
    outro_block = create(:block, identifier: "B", floors_count: 1, units_per_floor: 1)
    outra_unidade = outro_block.units.first
    outra_unidade.unit_number = 1
    outra_unidade.floor_number = 1
    assert outra_unidade.valid?
  end

  # Associações
  test "pertence a block" do
    assoc = Unit.reflect_on_association(:block)
    assert_equal :belongs_to, assoc.macro
  end

  test "tem muitos unit_residents" do
    assoc = Unit.reflect_on_association(:unit_residents)
    assert_equal :has_many, assoc.macro
    assert_equal :destroy, assoc.options[:dependent]
  end

  test "tem muitos residents através de unit_residents" do
    assoc = Unit.reflect_on_association(:residents)
    assert_equal :has_many, assoc.macro
    assert_equal :unit_residents, assoc.options[:through]
    assert_equal :user, assoc.options[:source]
  end

  test "tem muitos tickets" do
    assoc = Unit.reflect_on_association(:tickets)
    assert_equal :has_many, assoc.macro
    assert_equal :destroy, assoc.options[:dependent]
  end
end