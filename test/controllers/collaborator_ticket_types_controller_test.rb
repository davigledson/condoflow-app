require "test_helper"

class CollaboratorTicketTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @ticket_type = create(:ticket_type)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  test "não autenticado não pode criar atribuição" do
    post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    assert_redirected_to login_path
  end

  test "colaborador não pode criar atribuição" do
    login_as(@collaborator)
    post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode criar atribuição" do
    login_as(@admin)
    assert_difference "CollaboratorTicketType.count", 1 do
      post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    end
    assert_redirected_to edit_user_path(@collaborator)
    follow_redirect!
    assert_equal "Tipo de chamado atribuído.", flash[:notice]
  end

  test "admin não pode criar atribuição duplicada" do
    login_as(@admin)
    post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    assert_response :redirect
    assert_no_difference "CollaboratorTicketType.count" do
      post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    end
    assert_redirected_to edit_user_path(@collaborator)
    follow_redirect!
    assert_match /has already been taken/, flash[:alert]
  end

  test "admin tenta criar atribuição com ticket_type inexistente" do
    login_as(@admin)
    assert_no_difference "CollaboratorTicketType.count" do
      post assign_ticket_type_user_path(@collaborator), params: { ticket_type_id: -1 }
    end
    assert_redirected_to edit_user_path(@collaborator)
    follow_redirect!
    assert_match /encontrado|exist/, flash[:alert]
  end

  test "não autenticado não pode remover atribuição" do
    delete unassign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    assert_redirected_to login_path
  end

  test "colaborador não pode remover atribuição" do
    login_as(@collaborator)
    delete unassign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode remover atribuição existente" do
    login_as(@admin)
    create(:collaborator_ticket_type, user: @collaborator, ticket_type: @ticket_type)
    assert_difference "CollaboratorTicketType.count", -1 do
      delete unassign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    end
    assert_redirected_to edit_user_path(@collaborator)
    follow_redirect!
    assert_equal "Atribuição removida.", flash[:notice]
  end

  test "admin tenta remover atribuição inexistente" do
    login_as(@admin)
    assert_no_difference "CollaboratorTicketType.count" do
      delete unassign_ticket_type_user_path(@collaborator), params: { ticket_type_id: @ticket_type.id }
    end
    assert_response :not_found
  end
end