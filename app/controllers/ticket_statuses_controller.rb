class TicketStatusesController < ApplicationController
  before_action :require_admin!
  before_action :set_ticket_status, only: [:edit, :update, :destroy]

  def index
    @ticket_statuses = TicketStatus.all.order(:name).page(params[:page]).per(20)
  end

  def new
    @ticket_status = TicketStatus.new
  end

  def create
    @ticket_status = TicketStatus.new(ticket_status_params)
    if @ticket_status.save
      redirect_to ticket_statuses_path, notice: "Status criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ticket_status.update(ticket_status_params)
      redirect_to ticket_statuses_path, notice: "Status atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket_status.destroy
    redirect_to ticket_statuses_path, notice: "Status removido."
  end

  private

  def set_ticket_status
    @ticket_status = TicketStatus.find(params[:id])
  end

  def ticket_status_params
    params.require(:ticket_status).permit(:name, :is_default, :is_final)
  end
end