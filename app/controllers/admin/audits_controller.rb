class Admin::AuditsController < ApplicationController
  before_action :require_admin!

  def index
     # Aplicar filtros se enviados
  if params[:event_type].present?
    @events = @events.select { |e| e[:type].to_s == params[:event_type] }
  end

  if params[:user_id].present?
    @events = @events.select { |e| e[:user]&.id.to_s == params[:user_id] }
  end
  
    @status_histories = TicketStatusHistory
      .includes(:ticket, :ticket_status, :user)
      .order(created_at: :desc)
      .limit(200)

    @comments = Comment
      .includes(:ticket, :user)
      .order(created_at: :desc)
      .limit(200)

    @tickets = Ticket
      .includes(:user, :ticket_type, :ticket_status, unit: :block)
      .order(created_at: :desc)
      .limit(200)

    # Timeline unificada
    @events = [
      *@status_histories.map { |h|
        {
          type: :status_change,
          at: h.created_at,
          user: h.user,
          ticket: h.ticket,
          detail: h.ticket_status&.name
        }
      },
      *@comments.map { |c|
        {
          type: :comment,
          at: c.created_at,
          user: c.user,
          ticket: c.ticket,
          detail: c.body.truncate(80)
        }
      },
      *@tickets.map { |t|
        {
          type: :ticket_created,
          at: t.created_at,
          user: t.user,
          ticket: t,
          detail: t.ticket_type&.title
        }
      }
    ].sort_by { |e| e[:at] }.reverse.first(300)
  end
end