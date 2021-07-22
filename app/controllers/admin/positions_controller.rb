module Admin
class PositionsController < ApplicationController

  layout 'admin'
  load_and_authorize_resource
  before_action :set_position, only: [:show, :edit, :update, :destroy]

  def index
    if params[:status]
      @positions = Position.where(status: params[:status]).order(name: :asc)
    else
      @positions = Position.where(status: 'Activo').order(name: :asc)
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
  end

  def new
    @position = Position.new
  end

  def edit
  end

  def create
    @position = Position.create(position_params)

    respond_to do |format|
      if @position.save
        format.html { redirect_to admin_positions_url, notice: 'El rango se creó correctamente.' }
        format.json { render json: @position, status: :created, location: @position }
      else
        format.html { render :new }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @position.update(position_params)
        format.html { redirect_to admin_positions_url, notice: 'El rango se actualizó correctamente.' }
        format.json { render json: @position, status: :ok, location: @position }
      else
        format.html { render :edit }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @position.destroy
    respond_to do |format|
      format.html { redirect_to admin_positions_url, notice: 'El rango se eliminó correctamente.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_position
      @position = Position.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def position_params
      params.require(:position).permit(:name, :salary, :daily_viatical, :hours, :area_id, :status)
    end
end
end