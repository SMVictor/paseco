module Admin
  class MovementsController < ApplicationController
  	layout 'admin'
    load_and_authorize_resource
    before_action :set_movement, only: [:edit]

    def index
      @movements = Movement.joins(:employee).where('(employees.active =? AND movements.start_date <= ? AND movements.end_date >= ?) OR (employees.active =? AND movements.start_date <= ? AND movements.end_date IS ?)', true, Time.now, Time.now, true, Time.now, nil ).order(name: :asc, start_date: :asc)
    end

    def new
      @movement = Movement.new
    end

    def edit
      @movement.start_date = @movement.start_date.strftime('%d/%m/%Y')
      @movement.end_date   = @movement.end_date.strftime('%d/%m/%Y') if @movement.end_date
    end

    def create
      @movement = Movement.create(movement_params)

      respond_to do |format|
        if @movement.save
          format.html { redirect_to admin_movements_url, notice: 'La transacción se guardó correctamente.' }
          format.json { render json: @movement, status: :created, location: @movement }
        else
          format.html { render :new }
          format.json { render json: @movement.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @movement.update(movement_params)
          format.html { redirect_to admin_movements_url, notice: 'La transacción se guardó correctamente.' }
          format.json { render json: @movement, status: :ok, location: @movement }
        else
          format.html { render :edit }
          format.json { render json: @movement.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @movement.destroy
      respond_to do |format|
        format.html { redirect_to admin_movements_url, notice: 'La transacción se ejecutó correctamente.' }
      end
    end

    private
    def set_movement
        @movement = Movement.find(params[:id])
      end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movement_params
      params.require(:movement).permit(:start_date, :end_date, :affair, :way, :amount, :comment, :employee_id)
    end
  end
end