require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, email: "teste@exemplo.com", password: "123456", password_confirmation: "123456")
  end

  test "deve mostrar formulário de login" do
    get login_path
    assert_response :success
    assert_select "form[action='#{login_path}']", count: 1
  end

  test "login com credenciais válidas" do
    post login_path, params: { email: @user.email, password: "123456" }
    assert_redirected_to root_path
    follow_redirect!
    assert_equal "Bem-vindo, #{@user.name}!", flash[:notice]
    assert_equal @user.id, session[:user_id]
  end

  test "login com email inválido" do
    post login_path, params: { email: "invalido@exemplo.com", password: "123456" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match /Email ou senha inválidos/, response.body
  end

  test "login com senha inválida" do
    post login_path, params: { email: @user.email, password: "senha_errada" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match /Email ou senha inválidos/, response.body
  end

  test "logout deve encerrar sessão" do
    post login_path, params: { email: @user.email, password: "123456" }
    assert_equal @user.id, session[:user_id]

    delete logout_path
    assert_redirected_to login_path
    follow_redirect!
    assert_nil session[:user_id]
    assert_equal "Sessão encerrada.", flash[:notice]
  end
end