class CommentsController < ApplicationController
  before_action :set_ticket

  def create
    @comment = @ticket.comments.new(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to @ticket, notice: "Comentário adicionado."
    else
      redirect_to @ticket, alert: @comment.errors.full_messages.to_sentence
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def comment_params
    params.require(:comment).permit(:body, attachments: [])
  end
end