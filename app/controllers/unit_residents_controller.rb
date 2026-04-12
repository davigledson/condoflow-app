# Gerencia o vínculo morador <-> unidade (só admin)
class UnitResidentsController < ApplicationController
  before_action :require_admin!
  before_action :set_unit

  def create
    @unit_resident = UnitResident.new(unit_id: @unit.id, user_id: params[:user_id])
    if @unit_resident.save
      redirect_to @unit.block, notice: "Morador vinculado com sucesso."
    else
      redirect_to @unit.block, alert: @unit_resident.errors.full_messages.to_sentence
    end
  end

  def destroy
    @unit_resident = UnitResident.find_by!(unit_id: @unit.id, user_id: params[:user_id])
    @unit_resident.destroy
    redirect_to @unit.block, notice: "Vínculo removido."
  end

  private

  def set_unit
    @unit = Unit.find(params[:unit_id])
  end
end