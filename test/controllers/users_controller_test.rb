require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @resident = create(:user, :resident)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # ========== AUTENTICAÇÃO E AUTORIZAÇÃO ==========
  test "não autenticado não pode acessar index" do
    get users_path
    assert_redirected_to login_path
  end

  test "colaborador não pode acessar index" do
    login_as(@collaborator)
    get users_path
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode acessar index" do
    login_as(@admin)
    get users_path
    assert_response :success
  end

  # ========== NEW e CREATE ==========
  test "admin pode acessar new" do
    login_as(@admin)
    get new_user_path
    assert_response :success
  end

  test "admin pode criar usuário com dados válidos" do
    login_as(@admin)
    assert_difference "User.count", 1 do
      post users_path, params: {
        user: {
          name: "Novo Usuário",
          email: "novo@email.com",
          password: "123456",
          password_confirmation: "123456",
          role: :resident
        }
      }
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_equal "Usuário criado com sucesso.", flash[:notice]
  end

  test "admin não pode criar usuário com dados inválidos (email duplicado)" do
    login_as(@admin)
    assert_no_difference "User.count" do
      post users_path, params: {
        user: {
          name: "Duplicado",
          email: @resident.email,
          password: "123456",
          password_confirmation: "123456",
          role: :resident
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "form[action='#{users_path}']", count: 1
  end

  # ========== SHOW ==========
test "admin pode ver detalhes de um usuário" do
  login_as(@admin)
  get user_path(@resident)
  assert_response :success
  assert_match @resident.name, response.body
end

  test "admin tenta ver usuário inexistente" do
    login_as(@admin)
    get user_path(id: 99999)
    assert_redirected_to users_path
    assert_equal "Usuário não encontrado.", flash[:alert]
  end

  # ========== EDIT e UPDATE ==========
  test "admin pode acessar edit" do
    login_as(@admin)
    get edit_user_path(@resident)
    assert_response :success
  end

  test "admin pode atualizar usuário" do
    login_as(@admin)
    patch user_path(@resident), params: { user: { name: "Nome Atualizado" } }
    assert_redirected_to users_path
    follow_redirect!
    assert_equal "Usuário atualizado.", flash[:notice]
    assert_equal "Nome Atualizado", @resident.reload.name
  end

  test "admin não pode atualizar com email duplicado" do
    outro = create(:user, email: "outro@email.com")
    login_as(@admin)
    patch user_path(@resident), params: { user: { email: outro.email } }
    assert_response :unprocessable_entity
    assert_select "form[action='#{user_path(@resident)}']", count: 1
  end

  # ========== DESTROY ==========
  test "admin pode destruir usuário sem dependências" do
    usuario = create(:user, email: "temporario@email.com")
    login_as(@admin)
    assert_difference "User.count", -1 do
      delete user_path(usuario)
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_equal "Usuário removido.", flash[:notice]
  end

  test "admin não pode destruir a si mesmo" do
    login_as(@admin)
    assert_no_difference "User.count" do
      delete user_path(@admin)
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_equal "Você não pode remover seu próprio usuário.", flash[:alert]
  end

  test "admin não pode destruir usuário com dependências (ex: tickets)" do
    block = create(:block)
    unit = block.units.first
    create(:unit_resident, unit: unit, user: @resident)
    create(:ticket, unit: unit, user: @resident)

    login_as(@admin)
    assert_no_difference "User.count" do
      delete user_path(@resident)
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_match /existem registros dependentes/, flash[:alert]
  end
end