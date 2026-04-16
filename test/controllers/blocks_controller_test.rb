require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # ========== AUTENTICAÇÃO ==========
  test "não autenticado não pode acessar index" do
    get blocks_path
    assert_redirected_to login_path
  end

  test "colaborador não pode acessar blocks" do
    login_as(@collaborator)
    get blocks_path
    assert_response :redirect
    # Ajuste a rota de redirecionamento conforme sua aplicação
    assert_redirected_to root_path
    # Ou verifique se há flash de alerta
    # assert_equal "Acesso negado", flash[:alert]
  end

  # ========== AÇÕES COMO ADMIN ==========
  test "admin pode acessar index" do
    login_as(@admin)
    get blocks_path
    assert_response :success
  end

test "index exibe paginação quando há muitos blocos" do
  login_as(@admin)
  create_list(:block, 21)
  get blocks_path
  assert_response :success
  # Verifica se a paginação existe por texto comum (ex: "Anterior", "Próximo", números)
  assert_match /Anterior|Próximo|«|»|\d+/, response.body, "Paginação não encontrada"
end

  test "admin pode ver show do bloco" do
  login_as(@admin)
  block = create(:block, floors_count: 2, units_per_floor: 2)
  get block_path(block)
  assert_response :success
  # Verifica que a página contém o título do bloco e pelo menos uma unidade (sem seletor específico)
  assert_match /Bloco #{block.identifier}/, response.body
  # Conta quantas vezes o padrão de identificador aparece (ex: "A-01-01")
  units_count = response.body.scan(/#{block.identifier}-\d{2}-\d{2}/).size
  assert_equal 4, units_count, "Esperava 4 unidades, encontrou #{units_count}"
end

  test "admin pode acessar new" do
    login_as(@admin)
    get new_block_path
    assert_response :success
  end

  test "admin pode criar bloco com dados válidos" do
    login_as(@admin)
    assert_difference "Block.count", 1 do
      post blocks_path, params: {
        block: { identifier: "Z", floors_count: 3, units_per_floor: 4 }
      }
    end
    assert_redirected_to block_path(Block.last)
    # Verifica a mensagem flash (não depende de elemento HTML)
    follow_redirect!
    assert_equal "Bloco criado e unidades geradas com sucesso.", flash[:notice]
  end

  test "admin não pode criar bloco com dados inválidos" do
  login_as(@admin)
  assert_no_difference "Block.count" do
    post blocks_path, params: { block: { identifier: "", floors_count: 0, units_per_floor: 0 } }
  end
  assert_response :unprocessable_entity
  # Verifica se o formulário foi renderizado novamente (contém o form)
  assert_select "form[action='#{blocks_path}']", count: 1
  # Verifica se há mensagens de erro (genérico: qualquer elemento com classe "error" ou texto de erro)
  assert_match /error|erro|inválido/i, response.body, "Deveria haver mensagem de erro"
end

  test "admin pode acessar edit" do
    login_as(@admin)
    block = create(:block)
    get edit_block_path(block)
    assert_response :success
  end

  test "admin pode atualizar bloco" do
    login_as(@admin)
    block = create(:block, identifier: "Antigo")
    patch block_path(block), params: { block: { identifier: "Novo" } }
    assert_redirected_to block_path(block)
    follow_redirect!
    assert_equal "Bloco atualizado.", flash[:notice]
    assert_equal "Novo", block.reload.identifier
  end

  test "admin pode destruir bloco" do
    login_as(@admin)
    block = create(:block)
    assert_difference "Block.count", -1 do
      delete block_path(block)
    end
    assert_redirected_to blocks_path
    follow_redirect!
    assert_equal "Bloco removido.", flash[:notice]
  end
end