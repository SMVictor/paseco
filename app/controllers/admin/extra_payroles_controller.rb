module Admin
  class ExtraPayrolesController < ApplicationController
    
    layout 'admin'
    load_and_authorize_resource
    before_action :set_extra_payrole, only: [:show, :edit, :update, :destroy, :bncr_file]

    def index
      @extra_payroles = ExtraPayrole.all.order(name: :asc)
    end

    def new
      @extra_payrole = ExtraPayrole.new
    end

    def create
      @extra_payrole = ExtraPayrole.create(extra_payrole_params)

      respond_to do |format|
        if @extra_payrole.save
          format.html { redirect_to admin_extra_payroles_url, notice: 'El aguinaldo se creó correctamente.' }
          format.json { render json: @extra_payrole, status: :created, location: @extra_payrole }
        else
          format.html { render :new }
          format.json { render json: @extra_payrole.errors, status: :unprocessable_entity }
        end
      end
    end

    def show
      if params[:ids]
        @extra_payrole_lines = ChristmasBonification.where(id: params[:ids]).order(name: :asc)
        respond_to do |format|
          format.js
        end
      else
        @extra_payrole_lines = ChristmasBonification.where(from_date: @extra_payrole.from_date).order(name: :asc)
      end
    end

    def bncr_file
     @bn_info = BncrInfo.first
     @total = 0
     @sumAccounts = @bn_info.account[8,6].to_i

     ChristmasBonification.where(from_date: @extra_payrole.from_date).order(name: :asc).each do |christmas_bonification|
      if christmas_bonification.bank == "BNCR" && christmas_bonification.account != "" && christmas_bonification.total.to_i > 0 && christmas_bonification.employee.active
        @total += christmas_bonification.total.to_f.round(2)
        @sumAccounts += christmas_bonification.employee.account[8,6].to_i
      end
     end

     @total         = @total.round(2)
     @total_amount  = @total.to_s.split(".")[0]
     @total_decimal = "00"

     if  @total.to_s.split(".")[1]
       @total_decimal = @total.to_s.split(".")[1] + ("0" * (2 - @total.to_s.split(".")[1].length))
     end

     @total_amount_2  = (@total*2).to_s.split(".")[0]
     @total_decimal_2 = "00"

     if  (@total*2).to_s.split(".")[1]
       @total_decimal_2 = (@total*2).to_s.split(".")[1] + ("0" * (2 - (@total*2).to_s.split(".")[1].length))
     end

     respond_to do |format|
        format.xls
      end
    end

    def bac_file
     @bac_info = BacInfo.first
     @total = 0
     @count = 0

     ChristmasBonification.where(from_date: @extra_payrole.from_date).order(name: :asc).each do |extra_payrole|
      if extra_payrole.bank == "BAC" && extra_payrole.account != "" && extra_payrole.total.to_i > 0 && extra_payrole.employee.active
        @total += extra_payrole.total.to_f.round(2)
        @count += 1
      end
     end
     
     @total         = @total.round(2)
     @total_amount  = @total.to_s.split(".")[0]
     @total_decimal = "00"

     if  @total.to_s.split(".")[1]
       @total_decimal = @total.to_s.split(".")[1] + ("0" * (2 - @total.to_s.split(".")[1].length))
     end

     respond_to do |format|
        format.xls
      end
    end

    def edit_bonuses

      @employee      = Employee.find(params[:employee_id])
      @extra_payrole = ExtraPayrole.find(params[:extra_payrole])
      @bonus         = @employee.christmas_bonifications.where(from_date: @extra_payrole.from_date).first
      @lines         = []

      @bonus.christmas_bonification_lines.each do |line|
        if @lines[0] == nil
          @lines << line
        else
          flat = true
          @lines.each_with_index do |listed_line, index|
            if line.start_date.to_date > listed_line.start_date.to_date
              @lines.insert(index, line)
              flat = false
              break
            end
          end
          if flat
            @lines << line
          end
        end
      end
    end
    def update_bonuses
      @employee      = Employee.find(params[:employee_id])
      @extra_payrole = ExtraPayrole.find(params[:extra_payrole])
      @bonus = @employee.christmas_bonifications.find(params[:bonus])

      if @extra_payrole.to_date.to_date + 7.days > Time.now
        respond_to do |format|
          @bonus.update(bonus_params)
          total = 0

          @bonus.christmas_bonification_lines.each do |line|
            line.total = line.base_salary.to_f + line.extra_payment.to_f + line.viaticals.to_f
            total += line.total.to_f
          end

          @bonus.total = total / 12
          @bonus.save

          format.html { redirect_to admin_extra_payroles_show_path(@extra_payrole), notice: 'La información se actualizó correctamente.' }
          format.json { render json: @employee, status: :ok, location: @employee }
        end
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_extra_payrole
      @extra_payrole = ExtraPayrole.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extra_payrole_params
      params.require(:extra_payrole).permit(:name, :from_date, :to_date)
    end

    def bonus_params
      params.require(:christmas_bonification).permit(christmas_bonification_lines_attributes: [:id, :start_date, :end_date, :base_salary, :extra_payment, :viaticals, :_destroy])
    end

  end
end