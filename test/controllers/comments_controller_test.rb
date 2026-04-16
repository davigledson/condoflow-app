require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @resident = create(:user, :resident)

    @block = create(:block)
    @unit = @block.units.first
    create(:unit_resident, unit: @unit, user: @resident)

    @ticket_type = create(:ticket_type)
    @ticket_status = create(:ticket_status, is_default: true)
    @ticket = create(:ticket, unit: @unit, user: @resident, ticket_type: @ticket_type, ticket_status: @ticket_status)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  test "não autenticado não pode criar comentário" do
    assert_no_difference "Comment.count" do
      post ticket_comments_path(@ticket), params: { comment: { body: "Teste" } }
    end
    assert_redirected_to login_path
  end

  test "admin pode criar comentário em qualquer ticket" do
    login_as(@admin)
    assert_difference "Comment.count", 1 do
      post ticket_comments_path(@ticket), params: { comment: { body: "Comentário do admin" } }
    end
    assert_redirected_to ticket_path(@ticket)
    follow_redirect!
    assert_equal "Comentário adicionado.", flash[:notice]
  end

  test "colaborador pode criar comentário em qualquer ticket" do
    login_as(@collaborator)
    assert_difference "Comment.count", 1 do
      post ticket_comments_path(@ticket), params: { comment: { body: "Comentário do colaborador" } }
    end
    assert_redirected_to ticket_path(@ticket)
    follow_redirect!
    assert_equal "Comentário adicionado.", flash[:notice]
  end

  test "morador pode criar comentário em ticket da sua unidade" do
    login_as(@resident)
    assert_difference "Comment.count", 1 do
      post ticket_comments_path(@ticket), params: { comment: { body: "Meu comentário" } }
    end
    assert_redirected_to ticket_path(@ticket)
    follow_redirect!
    assert_equal "Comentário adicionado.", flash[:notice]
  end

test "morador não pode criar comentário em ticket de unidade que não pertence" do
  outro_resident = create(:user, :resident)
  outra_unidade = create(:block).units.first
  create(:unit_resident, unit: outra_unidade, user: outro_resident)

  outro_ticket = Ticket.create!(
    unit: outra_unidade,
    user: outro_resident,
    ticket_type: @ticket_type,
    ticket_status: @ticket_status,
    description: "Ticket de outro morador"
  )

  login_as(@resident)

  assert_no_difference "Comment.count" do
    post ticket_comments_path(outro_ticket), params: { comment: { body: "Tentativa inválida" } }
  end

  assert_redirected_to ticket_path(outro_ticket)
  follow_redirect!
  assert_match /não tem permissão|deve ser um colaborador|Chamado não encontrado/, flash[:alert]
end

  test "cria comentário com anexos" do
    login_as(@admin)
    file = fixture_file_upload(Rails.root.join("test/fixtures/files/example.txt"), "text/plain")
    assert_difference "Comment.count", 1 do
      post ticket_comments_path(@ticket), params: { comment: { body: "Com anexo", attachments: [file] } }
    end
    comment = Comment.last
    assert comment.attachments.attached?
    assert_redirected_to ticket_path(@ticket)
  end
end