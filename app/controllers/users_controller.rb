class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_users_with_alert
  rescue_from ActiveRecord::InvalidForeignKey, with: :redirect_to_users_with_alert

  def index
    @users = User.all.order(:name).page(params[:page]).per(20)
  end



  def show
  respond_to do |format|
    format.html
  end
end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "Usuário atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "Você não pode remover seu próprio usuário."
      return
    end

    @user.destroy
    redirect_to users_path, notice: "Usuário removido."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to users_path, alert: "Não foi possível remover: existem registros dependentes (chamados, comentários, etc.)."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def redirect_to_users_with_alert
    redirect_to users_path, alert: "Usuário não encontrado."
  end
end