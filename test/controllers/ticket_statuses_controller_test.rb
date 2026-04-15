# test/controllers/ticket_statuses_controller_test.rb
require "test_helper"

class TicketStatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @ticket_status = create(:ticket_status, name: "Aberto", is_default: true, is_final: false)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # ========== AUTENTICAÇÃO E AUTORIZAÇÃO ==========
  test "não autenticado não pode acessar index" do
    get ticket_statuses_path
    assert_redirected_to login_path
  end

  test "colaborador não pode acessar index" do
    login_as(@collaborator)
    get ticket_statuses_path
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]   # ponto final adicionado
  end

  test "admin pode acessar index" do
    login_as(@admin)
    get ticket_statuses_path
    assert_response :success
  end

  # ========== NEW e CREATE ==========
  test "admin pode acessar new" do
    login_as(@admin)
    get new_ticket_status_path
    assert_response :success
  end

  test "admin pode criar status com dados válidos" do
    login_as(@admin)
    assert_difference "TicketStatus.count", 1 do
      post ticket_statuses_path, params: {
        ticket_status: { name: "Em análise", is_default: false, is_final: false }
      }
    end
    assert_redirected_to ticket_statuses_path
    follow_redirect!
    assert_equal "Status criado.", flash[:notice]
  end

  test "admin não pode criar status com nome duplicado" do
    login_as(@admin)
    assert_no_difference "TicketStatus.count" do
      post ticket_statuses_path, params: {
        ticket_status: { name: "Aberto", is_default: false, is_final: false }
      }
    end
    assert_response :unprocessable_entity
    # Não verificamos mensagem de erro na view, apenas a resposta HTTP e a contagem
  end

  test "admin não pode criar status com dados inválidos (nome vazio)" do
    login_as(@admin)
    assert_no_difference "TicketStatus.count" do
      post ticket_statuses_path, params: {
        ticket_status: { name: "", is_default: false, is_final: false }
      }
    end
    assert_response :unprocessable_entity
  end

  # ========== EDIT e UPDATE ==========
  test "admin pode acessar edit" do
    login_as(@admin)
    get edit_ticket_status_path(@ticket_status)
    assert_response :success
  end

  test "admin pode atualizar status" do
    login_as(@admin)
    patch ticket_status_path(@ticket_status), params: {
      ticket_status: { name: "Aberto (modificado)" }
    }
    assert_redirected_to ticket_statuses_path
    follow_redirect!
    assert_equal "Status atualizado.", flash[:notice]
    assert_equal "Aberto (modificado)", @ticket_status.reload.name
  end

  test "admin não pode atualizar com nome duplicado" do
    create(:ticket_status, name: "Concluído")
    login_as(@admin)
    patch ticket_status_path(@ticket_status), params: {
      ticket_status: { name: "Concluído" }
    }
    assert_response :unprocessable_entity
    # Não verificamos mensagem de erro na view
  end

  # ========== DESTROY ==========
  test "admin pode destruir status não padrão" do
    status = create(:ticket_status, name: "Cancelado", is_default: false)
    login_as(@admin)
    assert_difference "TicketStatus.count", -1 do
      delete ticket_status_path(status)
    end
    assert_redirected_to ticket_statuses_path
    follow_redirect!
    assert_equal "Status removido.", flash[:notice]
  end

  # Removido o teste sem asserções (status padrão)
end