require "test_helper"

class UnitResidentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @collaborator = create(:user, :collaborator)
    @resident = create(:user, :resident)
    @block = create(:block, identifier: "A")
    @unit = @block.units.first
  end

  def login_as(user)
    post login_path, params: { email: user.email, password: "123456" }
    follow_redirect! if response.redirect?
  end

  # CREATE
  test "não autenticado não pode vincular morador" do
    post link_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    assert_redirected_to login_path
  end

  test "colaborador não pode vincular morador" do
    login_as(@collaborator)
    post link_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode vincular morador válido à unidade" do
    login_as(@admin)
    assert_difference "UnitResident.count", 1 do
      post link_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    end
    assert_redirected_to block_path(@block)
    follow_redirect!
    assert_equal "Morador vinculado com sucesso.", flash[:notice]
  end

  test "admin não pode vincular o mesmo morador duas vezes à mesma unidade" do
  create(:unit_resident, unit: @unit, user: @resident)
  login_as(@admin)
  assert_no_difference "UnitResident.count" do
    post link_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
  end
  assert_redirected_to block_path(@block)
  follow_redirect!
  assert_match /already been taken/, flash[:alert]
end

  test "admin não pode vincular usuário não residente (ex: admin ou colaborador)" do
    login_as(@admin)
    assert_no_difference "UnitResident.count" do
      post link_resident_block_unit_path(@block, @unit), params: { user_id: @admin.id }
    end
    assert_redirected_to block_path(@block)
    follow_redirect!
    assert_match /deve ter o papel de morador/, flash[:alert]
  end

  # DESTROY
  test "não autenticado não pode remover vínculo" do
    delete unlink_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    assert_redirected_to login_path
  end

  test "colaborador não pode remover vínculo" do
    login_as(@collaborator)
    delete unlink_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    assert_redirected_to root_path
    assert_equal "Acesso negado.", flash[:alert]
  end

  test "admin pode remover vínculo existente" do
    create(:unit_resident, unit: @unit, user: @resident)
    login_as(@admin)
    assert_difference "UnitResident.count", -1 do
      delete unlink_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    end
    assert_redirected_to block_path(@block)
    follow_redirect!
    assert_equal "Vínculo removido.", flash[:notice]
  end

  test "admin tenta remover vínculo inexistente" do
    login_as(@admin)
    assert_no_difference "UnitResident.count" do
      delete unlink_resident_block_unit_path(@block, @unit), params: { user_id: @resident.id }
    end
    assert_response :not_found
  end
end