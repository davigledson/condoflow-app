# app/controllers/unit_residents_controller.rb
class UnitResidentsController < ApplicationController
  before_action :require_admin!
  before_action :set_unit

  def create
    @unit_resident = UnitResident.new(unit: @unit, user_id: params[:user_id])
    if @unit_resident.save
      redirect_to block_path(@unit.block), notice: "Morador vinculado com sucesso."
    else
      redirect_to block_path(@unit.block), alert: @unit_resident.errors.full_messages.to_sentence
    end
  end

  def destroy
    @unit_resident = UnitResident.find_by!(unit: @unit, user_id: params[:user_id])
    @unit_resident.destroy
    redirect_to block_path(@unit.block), notice: "Vínculo removido."
  end

  private

  def set_unit
    @unit = Unit.find(params[:id])
  end
end