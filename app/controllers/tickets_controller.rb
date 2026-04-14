class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :update_status]

  def index
    @tickets = scoped_tickets.includes(:unit, :ticket_type, :ticket_status, :user)
                             .order(created_at: :desc)

    # Filtros (usados pelo collaborator e admin)
    @tickets = @tickets.where(ticket_status_id: params[:status_id]) if params[:status_id].present?
    @tickets = @tickets.where(ticket_type_id: params[:type_id])     if params[:type_id].present?
    @tickets = @tickets.joins(:unit).where(units: { block_id: params[:block_id] }) if params[:block_id].present?
  end

  def show
    @comments = @ticket.comments.includes(:user).order(created_at: :asc)
    @comment  = Comment.new
  end

  def new
    redirect_to root_path, alert: "Acesso negado." unless current_user.resident?
    @ticket = Ticket.new
    @units  = current_user.units
  end

  def create
    redirect_to root_path, alert: "Acesso negado." unless current_user.resident?
    @ticket = Ticket.new(ticket_params.merge(user: current_user))
    if @ticket.save
      redirect_to @ticket, notice: "Chamado aberto com sucesso."
    else
      @units = current_user.units
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /tickets/:id/update_status — só admin e collaborator
  def update_status
    require_admin_or_collaborator!

    previous_status = @ticket.ticket_status
    if @ticket.update(ticket_status_id: params[:ticket_status_id])
      # Registra no histórico
      @ticket.ticket_status_histories.create!(
        ticket_status: @ticket.ticket_status,
        user: current_user
      )
      redirect_to @ticket, notice: "Status atualizado."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  private

  def set_ticket
    @ticket = scoped_tickets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tickets_path, alert: "Chamado não encontrado."
  end

  # Define o escopo de visibilidade por papel
  def scoped_tickets
    if current_user.admin?
      Ticket.all
    elsif current_user.collaborator?
      # Vê apenas chamados dos tipos que é responsável
    Ticket.where(ticket_type: current_user.assigned_ticket_types)
    else
      # Morador vê apenas chamados das suas unidades
      Ticket.where(unit: current_user.units)
    end
  end

  def ticket_params
    params.require(:ticket).permit(:unit_id, :ticket_type_id, :description)
  end
end