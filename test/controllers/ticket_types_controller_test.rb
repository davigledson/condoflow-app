require "test_helper"

class TicketTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @ticket_type = create(:ticket_type, title: "Manutenção", sla_hours: 24)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # ========== AUTENTICAÇÃO E AUTORIZAÇÃO ==========
  test "não autenticado não pode acessar index" do
    get ticket_types_path
    assert_redirected_to login_path
  end

  test "colaborador não pode acessar index" do
    login_as(@collaborator)
    get ticket_types_path
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode acessar index" do
    login_as(@admin)
    get ticket_types_path
    assert_response :success
  end

  # ========== NEW e CREATE ==========
  test "admin pode acessar new" do
    login_as(@admin)
    get new_ticket_type_path
    assert_response :success
  end

  test "admin pode criar tipo de chamado com dados válidos" do
    login_as(@admin)
    assert_difference "TicketType.count", 1 do
      post ticket_types_path, params: {
        ticket_type: { title: "Elétrica", sla_hours: 48 }
      }
    end
    assert_redirected_to ticket_types_path
    follow_redirect!
    assert_equal "Tipo de chamado criado.", flash[:notice]
  end

  test "admin não pode criar tipo de chamado com título duplicado" do
    login_as(@admin)
    assert_no_difference "TicketType.count" do
      post ticket_types_path, params: {
        ticket_type: { title: "Manutenção", sla_hours: 30 }
      }
    end
    assert_response :unprocessable_entity
  end

  test "admin não pode criar tipo de chamado com dados inválidos (título vazio)" do
    login_as(@admin)
    assert_no_difference "TicketType.count" do
      post ticket_types_path, params: {
        ticket_type: { title: "", sla_hours: 24 }
      }
    end
    assert_response :unprocessable_entity
  end

  test "admin não pode criar tipo de chamado com sla_hours inválido (zero)" do
    login_as(@admin)
    assert_no_difference "TicketType.count" do
      post ticket_types_path, params: {
        ticket_type: { title: "Teste", sla_hours: 0 }
      }
    end
    assert_response :unprocessable_entity
  end

  # ========== EDIT e UPDATE ==========
  test "admin pode acessar edit" do
    login_as(@admin)
    get edit_ticket_type_path(@ticket_type)
    assert_response :success
  end

  test "admin pode atualizar tipo de chamado" do
    login_as(@admin)
    patch ticket_type_path(@ticket_type), params: {
      ticket_type: { title: "Manutenção Corretiva", sla_hours: 36 }
    }
    assert_redirected_to ticket_types_path
    follow_redirect!
    assert_equal "Tipo de chamado atualizado.", flash[:notice]
    assert_equal "Manutenção Corretiva", @ticket_type.reload.title
    assert_equal 36, @ticket_type.reload.sla_hours
  end

  test "admin não pode atualizar com título duplicado" do
    create(:ticket_type, title: "Hidráulica")
    login_as(@admin)
    patch ticket_type_path(@ticket_type), params: {
      ticket_type: { title: "Hidráulica", sla_hours: 24 }
    }
    assert_response :unprocessable_entity
    assert_equal "Manutenção", @ticket_type.reload.title
  end

  test "admin não pode atualizar com sla_hours inválido (negativo)" do
    login_as(@admin)
    patch ticket_type_path(@ticket_type), params: {
      ticket_type: { title: "Manutenção", sla_hours: -5 }
    }
    assert_response :unprocessable_entity
    assert_equal 24, @ticket_type.reload.sla_hours
  end

  # ========== DESTROY ==========
  test "admin pode destruir tipo de chamado sem dependências" do
    tipo = create(:ticket_type, title: "Limpeza", sla_hours: 12)
    login_as(@admin)
    assert_difference "TicketType.count", -1 do
      delete ticket_type_path(tipo)
    end
    assert_redirected_to ticket_types_path
    follow_redirect!
    assert_equal "Tipo de chamado removido.", flash[:notice]
  end

  test "admin não pode destruir tipo de chamado que possui tickets associados" do
    block = create(:block)
    unit = block.units.first
    resident = create(:user, :resident)
    create(:unit_resident, unit: unit, user: resident)
    create(:ticket, ticket_type: @ticket_type, unit: unit, user: resident)

    login_as(@admin)
    assert_no_difference "TicketType.count" do
      delete ticket_type_path(@ticket_type)
    end
    assert_redirected_to ticket_types_path
    # Mensagem correta de acordo com o rescue_from no controller
    assert_match /existem chamados vinculados a este tipo/, flash[:alert]
  end
end