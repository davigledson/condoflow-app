# app/controllers/blocks_controller.rb
class BlocksController < ApplicationController
  before_action :require_admin!
  before_action :set_block, only: [:show, :edit, :update, :destroy]

  def index
    @blocks = Block.includes(:units).order(:identifier)
  end

  def show
    @units = @block.units.order(:floor_number, :unit_number)
  end

  def new
    @block = Block.new
  end

  def create
    @block = Block.new(block_params)
    if @block.save
      redirect_to @block, notice: "Bloco criado e unidades geradas com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @block.update(block_params)
      redirect_to @block, notice: "Bloco atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @block.destroy
    redirect_to blocks_path, notice: "Bloco removido."
  end

  private

  def set_block
    @block = Block.find(params[:id])
  end

  def block_params
    params.require(:block).permit(:identifier, :floors_count, :units_per_floor)
  end
end