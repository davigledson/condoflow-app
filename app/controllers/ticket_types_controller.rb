# app/controllers/ticket_types_controller.rb
class TicketTypesController < ApplicationController
  before_action :require_admin!
  before_action :set_ticket_type, only: [:edit, :update, :destroy]

  def index
     @ticket_types = TicketType.all.order(:title).page(params[:page]).per(20)
  end

  def new
    @ticket_type = TicketType.new
  end

  def create
    @ticket_type = TicketType.new(ticket_type_params)
    if @ticket_type.save
      redirect_to ticket_types_path, notice: "Tipo de chamado criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ticket_type.update(ticket_type_params)
      redirect_to ticket_types_path, notice: "Tipo de chamado atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket_type.destroy
    redirect_to ticket_types_path, notice: "Tipo de chamado removido."
  end

  private

  def set_ticket_type
    @ticket_type = TicketType.find(params[:id])
  end

  def ticket_type_params
    params.require(:ticket_type).permit(:title, :sla_hours)
  end
end