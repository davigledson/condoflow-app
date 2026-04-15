require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Usuários
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @resident = create(:user, :resident)

    # Bloco e unidade
    @block = create(:block, identifier: "A")
    @unit = @block.units.first

    # Vincula residente à unidade
    create(:unit_resident, unit: @unit, user: @resident)

    # Tipos de chamado e status
    @ticket_type = create(:ticket_type, title: "Elétrica", sla_hours: 24)
    @other_ticket_type = create(:ticket_type, title: "Hidráulica", sla_hours: 48)
    @status_aberto = create(:ticket_status, name: "Aberto", is_default: true, is_final: false)
    @status_concluido = create(:ticket_status, name: "Concluído", is_default: false, is_final: true)

    # Ticket criado pelo residente
    @ticket = create(:ticket, unit: @unit, user: @resident, ticket_type: @ticket_type, ticket_status: @status_aberto)

    # Colaborador com permissão para o tipo Elétrica
    create(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # ========== AUTENTICAÇÃO ==========
  test "não autenticado não pode acessar index" do
    get tickets_path
    assert_redirected_to login_path
  end

  test "não autenticado não pode acessar show" do
    get ticket_path(@ticket)
    assert_redirected_to login_path
  end

  test "não autenticado não pode acessar new" do
    get new_ticket_path
    assert_redirected_to login_path
  end

  test "não autenticado não pode criar ticket" do
    assert_no_difference "Ticket.count" do
      post tickets_path, params: { ticket: { unit_id: @unit.id, ticket_type_id: @ticket_type.id, description: "Teste" } }
    end
    assert_redirected_to login_path
  end

  test "não autenticado não pode atualizar status" do
    patch update_status_ticket_path(@ticket), params: { ticket_status_id: @status_concluido.id }
    assert_redirected_to login_path
  end

  # ========== ADMIN ==========
  test "admin pode ver lista de todos os tickets" do
    login_as(@admin)
    get tickets_path
    assert_response :success
    assert_select "h1", text: /Chamados/i
  end

  test "admin pode ver detalhe de qualquer ticket" do
    login_as(@admin)
    get ticket_path(@ticket)
    assert_response :success
    assert_match @ticket.description, response.body
  end

  test "admin não pode acessar new (apenas residente)" do
    login_as(@admin)
    get new_ticket_path
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

test "admin não pode criar ticket" do
  login_as(@admin)
  assert_no_difference "Ticket.count" do
    post tickets_path, params: { ticket: { unit_id: @unit.id, ticket_type_id: @ticket_type.id, description: "Admin tentando" } }
  end
  assert_redirected_to root_path
  assert_equal "Acesso negado.", flash[:alert]
end

  test "admin pode atualizar status de qualquer ticket" do
    login_as(@admin)
    assert_difference "TicketStatusHistory.count", 1 do
      patch update_status_ticket_path(@ticket), params: { ticket_status_id: @status_concluido.id }
    end
    assert_redirected_to ticket_path(@ticket)
    follow_redirect!
    assert_equal "Status atualizado.", flash[:notice]
    assert_equal @status_concluido, @ticket.reload.ticket_status
  end

  # ========== COLABORADOR ==========
test "colaborador vê apenas tickets dos tipos atribuídos" do
  # Cria um ticket de outro tipo (não atribuído ao colaborador)
  outro_ticket = create(:ticket, ticket_type: @other_ticket_type, unit: @unit, user: @resident)

  login_as(@collaborator)
  get tickets_path
  assert_response :success

  # Deve ver o ticket do tipo atribuído (Elétrica)
  assert_select "a[href='#{ticket_path(@ticket)}']", text: "Ver"
  # Não deve ver o ticket de tipo não atribuído (Hidráulica)
  assert_select "a[href='#{ticket_path(outro_ticket)}']", text: "Ver", count: 0
end

  test "colaborador pode ver detalhe de ticket do tipo atribuído" do
    login_as(@collaborator)
    get ticket_path(@ticket)
    assert_response :success
    assert_match @ticket.description, response.body
  end

  test "colaborador não pode ver detalhe de ticket de tipo não atribuído" do
    outro_ticket = create(:ticket, ticket_type: @other_ticket_type, unit: @unit, user: @resident)
    login_as(@collaborator)
    get ticket_path(outro_ticket)
    assert_redirected_to tickets_path
    assert_equal "Chamado não encontrado.", flash[:alert]
  end

  test "colaborador não pode acessar new (apenas residente)" do
    login_as(@collaborator)
    get new_ticket_path
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

test "colaborador não pode criar ticket" do
  login_as(@collaborator)
  assert_no_difference "Ticket.count" do
    post tickets_path, params: { ticket: { unit_id: @unit.id, ticket_type_id: @ticket_type.id, description: "Teste" } }
  end
  assert_redirected_to root_path
  assert_equal "Acesso negado.", flash[:alert]
end

  test "colaborador pode atualizar status de ticket do tipo atribuído" do
    login_as(@collaborator)
    assert_difference "TicketStatusHistory.count", 1 do
      patch update_status_ticket_path(@ticket), params: { ticket_status_id: @status_concluido.id }
    end
    assert_redirected_to ticket_path(@ticket)
    assert_equal "Status atualizado.", flash[:notice]
    assert_equal @status_concluido, @ticket.reload.ticket_status
  end

  test "colaborador não pode atualizar status de ticket de tipo não atribuído" do
    outro_ticket = create(:ticket, ticket_type: @other_ticket_type, unit: @unit, user: @resident)
    login_as(@collaborator)
    patch update_status_ticket_path(outro_ticket), params: { ticket_status_id: @status_concluido.id }
    assert_redirected_to tickets_path
    assert_equal "Chamado não encontrado.", flash[:alert]
  end

  # ========== MORADOR ==========
  test "morador vê apenas seus tickets (das suas unidades)" do
  outra_unidade = create(:block).units.first
  outro_resident = create(:user, :resident)
  create(:unit_resident, unit: outra_unidade, user: outro_resident)
  ticket_outro = create(:ticket, unit: outra_unidade, user: outro_resident)

  login_as(@resident)
  get tickets_path
  assert_response :success
  # Verifica se o ticket do residente aparece (pelo link 'Ver')
  assert_select "a[href='#{ticket_path(@ticket)}']", text: "Ver"
  # Verifica que o ticket do outro residente NÃO aparece
  assert_select "a[href='#{ticket_path(ticket_outro)}']", text: "Ver", count: 0
end

  test "morador pode ver detalhe de seu ticket" do
    login_as(@resident)
    get ticket_path(@ticket)
    assert_response :success
  end

  test "morador não pode ver detalhe de ticket de outra unidade" do
    outra_unidade = create(:block).units.first
    outro_resident = create(:user, :resident)
    create(:unit_resident, unit: outra_unidade, user: outro_resident)
    ticket_outro = create(:ticket, unit: outra_unidade, user: outro_resident)

    login_as(@resident)
    get ticket_path(ticket_outro)
    assert_redirected_to tickets_path
    assert_equal "Chamado não encontrado.", flash[:alert]
  end

  test "morador pode acessar new" do
    login_as(@resident)
    get new_ticket_path
    assert_response :success
    assert_select "select[name='ticket[unit_id]']" # verifica se mostra as unidades do morador
  end

  test "morador pode criar ticket" do
    login_as(@resident)
    assert_difference "Ticket.count", 1 do
      post tickets_path, params: {
        ticket: {
          unit_id: @unit.id,
          ticket_type_id: @ticket_type.id,
          description: "Problema no hall"
        }
      }
    end
    assert_redirected_to ticket_path(Ticket.last)
    follow_redirect!
    assert_equal "Chamado aberto com sucesso.", flash[:notice]
  end

  test "morador não pode criar ticket com dados inválidos" do
    login_as(@resident)
    assert_no_difference "Ticket.count" do
      post tickets_path, params: { ticket: { unit_id: nil, ticket_type_id: nil, description: "" } }
    end
    assert_response :unprocessable_entity
    assert_select "form[action='#{tickets_path}']" # formulário é re-renderizado
  end

  test "morador não pode atualizar status do ticket (não tem permissão)" do
    login_as(@resident)
    patch update_status_ticket_path(@ticket), params: { ticket_status_id: @status_concluido.id }
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  # ========== FILTROS ==========
test "admin pode filtrar tickets por status" do
  outro_status = create(:ticket_status, name: "Em andamento")
  outro_ticket = create(:ticket, ticket_status: outro_status)
  login_as(@admin)
  get tickets_path, params: { status_id: @status_aberto.id }
  assert_response :success
  # Verifica que o ticket com status "Aberto" aparece
  assert_select "a[href='#{ticket_path(@ticket)}']", text: "Ver"
  # Verifica que o ticket com status "Em andamento" não aparece
  assert_select "a[href='#{ticket_path(outro_ticket)}']", text: "Ver", count: 0
end

test "admin pode filtrar tickets por bloco" do
  # Cria outro bloco, unidade e residente (válido)
  outro_bloco = create(:block, identifier: "B")
  outra_unidade = outro_bloco.units.first
  outro_resident = create(:user, :resident)
  create(:unit_resident, unit: outra_unidade, user: outro_resident)
  outro_ticket = create(:ticket, unit: outra_unidade, user: outro_resident, ticket_type: @ticket_type)

  login_as(@admin)
  get tickets_path, params: { block_id: @block.id }
  assert_response :success

  # Deve mostrar o ticket do bloco A
  assert_select "a[href='#{ticket_path(@ticket)}']", text: "Ver"
  # Não deve mostrar o ticket do bloco B
  assert_select "a[href='#{ticket_path(outro_ticket)}']", text: "Ver", count: 0
end


  # ========== TRATAMENTO DE ERROS ==========
  test "acessar ticket inexistente redireciona com mensagem" do
    login_as(@admin)
    get ticket_path(id: 99999)
    assert_redirected_to tickets_path
    assert_equal "Chamado não encontrado.", flash[:alert]
  end

  test "atualizar status com ID inválido (não encontrado) redireciona" do
    login_as(@admin)
    patch update_status_ticket_path(99999), params: { ticket_status_id: @status_concluido.id }
    assert_redirected_to tickets_path
    assert_equal "Chamado não encontrado.", flash[:alert]
  end

  test "atualizar status com status inválido (ex: nil) não cria histórico e mostra erro" do
    login_as(@admin)
    # Supondo que a atualização falhe (status inválido)
    patch update_status_ticket_path(@ticket), params: { ticket_status_id: nil }
    assert_redirected_to ticket_path(@ticket)
    assert_match /Ticket status must exist/, flash[:alert]
    assert_no_difference "TicketStatusHistory.count" do
      patch update_status_ticket_path(@ticket), params: { ticket_status_id: nil }
    end
  end
end