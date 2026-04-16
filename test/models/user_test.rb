require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ========== VALIDAÇÕES ==========
  test "é válido com atributos válidos" do
    user = build(:user)
    assert user.valid?
  end

  test "é inválido sem name" do
    user = build(:user, name: nil)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "é inválido sem email" do
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "é inválido com email duplicado" do
    create(:user, email: "duplicado@example.com")
    user = build(:user, email: "duplicado@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "é inválido com email mal formatado" do
    user = build(:user, email: "invalido")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "é inválido sem role" do
    user = build(:user, role: nil)
    assert_not user.valid?
    assert_includes user.errors[:role], "can't be blank"
  end

  # ========== HAS_SECURE_PASSWORD ==========
  test "requer password na criação" do
    user = build(:user, password: nil, password_confirmation: nil)
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "password_confirmation deve corresponder" do
    user = build(:user, password: "123456", password_confirmation: "diferente")
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "authenticate retorna usuário com senha correta" do
    user = create(:user, password: "123456", password_confirmation: "123456")
    assert user.authenticate("123456")
    assert_not user.authenticate("senha_errada")
  end

  # ========== ENUM ROLE ==========
  test "enum role define valores corretos" do
    assert_equal 0, User.roles[:admin]
    assert_equal 1, User.roles[:collaborator]
    assert_equal 2, User.roles[:resident]
  end

  test "admin? retorna true para admin" do
    admin = create(:user, :admin)
    assert admin.admin?
    assert_not admin.collaborator?
    assert_not admin.resident?
  end

  test "collaborator? retorna true para collaborator" do
    collaborator = create(:user, :collaborator)
    assert collaborator.collaborator?
    assert_not collaborator.admin?
    assert_not collaborator.resident?
  end

  test "resident? retorna true para resident" do
    resident = create(:user, :resident)
    assert resident.resident?
    assert_not resident.admin?
    assert_not resident.collaborator?
  end

  test "role padrão é resident" do
    user = User.new
    assert_equal "resident", user.role
  end

  # ========== ASSOCIAÇÕES ==========
  test "tem muitos unit_residents" do
    assoc = User.reflect_on_association(:unit_residents)
    assert_equal :has_many, assoc.macro
    assert_equal :destroy, assoc.options[:dependent]
  end

  test "tem muitas units através de unit_residents" do
    assoc = User.reflect_on_association(:units)
    assert_equal :has_many, assoc.macro
    assert_equal :unit_residents, assoc.options[:through]
  end

  test "tem muitos tickets" do
    assoc = User.reflect_on_association(:tickets)
    assert_equal :has_many, assoc.macro
  end

  test "tem muitos comments" do
    assoc = User.reflect_on_association(:comments)
    assert_equal :has_many, assoc.macro
  end

  test "tem muitos ticket_status_histories" do
    assoc = User.reflect_on_association(:ticket_status_histories)
    assert_equal :has_many, assoc.macro
  end

  test "tem muitos collaborator_ticket_types" do
    assoc = User.reflect_on_association(:collaborator_ticket_types)
    assert_equal :has_many, assoc.macro
    assert_equal :destroy, assoc.options[:dependent]
  end

  test "tem muitos assigned_ticket_types através de collaborator_ticket_types" do
    assoc = User.reflect_on_association(:assigned_ticket_types)
    assert_equal :has_many, assoc.macro
    assert_equal :collaborator_ticket_types, assoc.options[:through]
    assert_equal :ticket_type, assoc.options[:source]
  end
end