# app/controllers/collaborator_ticket_types_controller.rb
class CollaboratorTicketTypesController < ApplicationController
  before_action :require_admin!
  before_action :set_user

  def create
    @link = CollaboratorTicketType.new(user: @user, ticket_type_id: params[:ticket_type_id])
    if @link.save
      redirect_to edit_user_path(@user), notice: "Tipo de chamado atribuído."
    else
      redirect_to edit_user_path(@user), alert: @link.errors.full_messages.to_sentence
    end
  end

  def destroy
    @link = CollaboratorTicketType.find_by!(user: @user, ticket_type_id: params[:ticket_type_id])
    @link.destroy
    redirect_to edit_user_path(@user), notice: "Atribuição removida."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end