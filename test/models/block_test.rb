require "test_helper"

class BlockTest < ActiveSupport::TestCase
  setup do
    # Cria um bloco válido (não salvo) para usar nos testes de validação
    @block = build(:block)
  end

  # ========== VALIDAÇÕES ==========
  test "é válido com atributos válidos" do
    assert @block.valid?
  end

  test "é inválido sem identifier" do
    @block.identifier = nil
    assert_not @block.valid?
    assert_includes @block.errors[:identifier], "can't be blank"
  end

  test "é inválido com identifier duplicado" do
    create(:block, identifier: "X1")
    block_dup = build(:block, identifier: "X1")
    assert_not block_dup.valid?
    assert_includes block_dup.errors[:identifier], "has already been taken"
  end

  test "é inválido sem floors_count" do
    @block.floors_count = nil
    assert_not @block.valid?
    assert_includes @block.errors[:floors_count], "can't be blank"
  end

  test "floors_count deve ser maior que zero" do
    @block.floors_count = 0
    assert_not @block.valid?
    assert_includes @block.errors[:floors_count], "must be greater than 0"

    @block.floors_count = -1
    assert_not @block.valid?
    assert_includes @block.errors[:floors_count], "must be greater than 0"
  end

  test "é inválido sem units_per_floor" do
    @block.units_per_floor = nil
    assert_not @block.valid?
    assert_includes @block.errors[:units_per_floor], "can't be blank"
  end

  test "units_per_floor deve ser maior que zero" do
    @block.units_per_floor = 0
    assert_not @block.valid?
    assert_includes @block.errors[:units_per_floor], "must be greater than 0"
  end

  # ========== CRIAÇÃO DE UNIDADES (after_create) ==========
  test "ao criar um bloco, gera unidades automaticamente" do
    assert_difference "Unit.count", 2 * 3 do
      create(:block, floors_count: 2, units_per_floor: 3)
    end
  end

  test "as unidades geradas têm os identificadores corretos" do
    block = create(:block, identifier: "C", floors_count: 2, units_per_floor: 2)
    expected_identifiers = [
      "C-01-01",
      "C-01-02",
      "C-02-01",
      "C-02-02"
    ]
    actual_identifiers = block.units.order(:floor_number, :unit_number).pluck(:identifier)
    assert_equal expected_identifiers, actual_identifiers
  end

  test "unidades são criadas com floor_number e unit_number corretos" do
    block = create(:block, floors_count: 2, units_per_floor: 2)
    units = block.units.order(:floor_number, :unit_number)
    assert_equal [1, 1, 2, 2], units.map(&:floor_number)
    assert_equal [1, 2, 1, 2], units.map(&:unit_number)
  end

  # ========== RELACIONAMENTOS ==========
  test "ao destruir um bloco, suas unidades também são destruídas" do
    block = create(:block, floors_count: 1, units_per_floor: 1)
    unit = block.units.first
    assert_difference "Unit.count", -1 do
      block.destroy
    end
    assert_raises(ActiveRecord::RecordNotFound) { unit.reload }
  end

  test "responde a has_many :units" do
    assert_respond_to @block, :units
  end
end