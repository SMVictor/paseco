module Admin
  class EmployeesController < ApplicationController

    layout 'admin', except: [:vacations_file]
    load_and_authorize_resource
    before_action :set_employee, only: [:show, :show_inactive, :edit, :edit_inactive, :update, :update_inactive, :destroy, :edit_vacations, :update_vacations, :edit_vacations_inactive, :update_vacations_inactive]

    def index
      if params[:ids]
        @employees = Employee.where(id: params[:ids], active: true).all.order(name: :asc)
        respond_to do |format|
          format.js
        end
      else
        @employees = Employee.where(active: true).order(name: :asc)
      end
    end

    def inactives
      if params[:ids]
        @employees = Employee.where(id: params[:ids], active: false).order(name: :asc)
        respond_to do |format|
          format.js
        end
      else
        @employees = Employee.where(active: false).order(name: :asc)
      end
    end

    def show
      sort_entries
      @employee.calculate_vacations
      sort_vacations
      sort_disabilities
      sort_movements
      update_christmas_bonuses(@employee)
    end

    def show_inactive
      sort_entries
      @employee.calculate_vacations
      sort_vacations
    end

    def new
      @employee = Employee.new
    end

    def edit
      sort_entries
      @employee.calculate_vacations
      sort_vacations
      sort_disabilities
      sort_movements
      update_christmas_bonuses(@employee)
    end

    def edit_inactive
      sort_entries
      @employee.calculate_vacations
      sort_vacations
    end

    def create
      @employee = Employee.create(employee_params)

      respond_to do |format|
        if @employee.save
          format.html { redirect_to admin_employees_url, notice: 'El empleado se creó correctamente.' }
          format.json { render json: @employee, status: :created, location: @employee }
        else
          format.html { render :new }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
    end

    def update

      # Destroy current Christmas bonus
      if params[:employee][:active] == "0" 
        bonuses = @employee.christmas_bonifications.where(from_date: '01/12/'+(Time.now.year-1).to_s)
        if bonuses != []
          bonuses.first.christmas_bonification_lines.destroy_all
          bonuses.first.destroy
        end
      end

      # Mark the account as 'Not Registered'
      if params[:employee][:account] != @employee.account
        params[:employee][:registered_account] = false
      end

      respond_to do |format|
        if @employee.update(employee_params)

          #Update current payrole information.
          last_payrole_line = PayroleLine.where(role_id: Role.last.id, employee_id: @employee.id)
          if last_payrole_line != []
            last_payrole_line = last_payrole_line.first
            if (DateTime.parse(Role.last.end_date) + 5.days) > Date.today
              last_payrole_line.name            = @employee.name
              last_payrole_line.bank            = @employee.bank
              last_payrole_line.ccss_type       = @employee.ccss_type == 'yes'? 'Completo' : 'Normal'
              last_payrole_line.social_security = @employee.social_security
              last_payrole_line.account         = @employee.account
              last_payrole_line.save
            end
          end
          

          format.html { redirect_to admin_employees_url, notice: 'El empleado se actualizó correctamente.' }
          format.json { render json: @employee, status: :ok, location: @employee }
        else
          format.html { render :edit }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_inactive
      respond_to do |format|
        if @employee.update(employee_params)
          format.html { redirect_to admin_inactive_employees_url, notice: 'El empleado se actualizó correctamente.' }
          format.json { render json: @employee, status: :ok, location: @employee }
        else
          format.html { render :edit_inactive }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @employee.destroy
      respond_to do |format|
        format.html { redirect_to admin_employees_url, notice: 'El empleado se eliminó correctamente.' }
      end
    end

    def destroy_inactive
      @employee.destroy
      respond_to do |format|
        format.html { redirect_to admin_inactive_employees_url, notice: 'El empleado se eliminó correctamente.' }
      end
    end

    def vacations_file

      @date = params[:date]
      @employee_name = params[:employee_name]
      @employee_identification = params[:employee_identification]
      @area = params[:area]
      @stall = params[:stall]
      @entry_date = params[:entry_date]
      @departure_date = params[:departure_date]
      @avalaible_days = params[:avalaible_days]
      @used_days = params[:used_days]
      @requested_days = params[:requested_days]
      @total_days = params[:total_days]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @period = params[:period]

      respond_to do |format|
        format.html
      end
    end

    def edit_vacations
      @employee.calculate_vacations
    end

    def update_vacations
      respond_to do |format|
        if @employee.update(employee_params)
          format.html { redirect_to admin_employee_path(@employee), notice: 'El empleado se actualizó correctamente.' }
          format.json { render json: @employee, status: :ok, location: @employee }
        else
          format.html { render :show }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit_vacations_inactive
      @employee.calculate_vacations
    end

    def update_vacations_inactive
      respond_to do |format|
        if @employee.update(employee_params)
          format.html { redirect_to admin_show_inactive_employee_path(@employee), notice: 'El empleado se actualizó correctamente.' }
          format.json { render json: @employee, status: :ok, location: @employee }
        else
          format.html { render :show }
          format.json { render json: @employee.errors, status: :unprocessable_entity }
        end
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_employee
        @employee = Employee.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def employee_params
        params.require(:employee).permit(:name, :identification, :account_owner, :account_identification, :id_type, :birthday, :gender, :ccss_number, :province, :canton, :district, :other, :phone, :phone_1, :emergency_contact, :emergency_number, :payment_method, :bank, :account, :social_security, :daily_viatical, :ccss_type, :special, :active, :retired, :registered_account, :email, :has_christmas_bonus, sub_service_ids: [], stall_ids: [], position_ids: [], entries_attributes: [:id, :start_date, :end_date, :document, :reason_departure, :_destroy], vacations_attributes: [:id, :start_date, :end_date, :included_freedays, :requested_days, :period, :date,  :_destroy], disabilities_attributes: [:id, :start_date, :end_date, :institution, :_destroy], movements_attributes: [:id, :start_date, :end_date, :affair, :type, :way, :amount, :comment, :_destroy])
      end

      def sort_vacations
        position = 0

        while position < @employee.vacations.size
          
          start_date        = @employee.vacations[position].start_date
          end_date          = @employee.vacations[position].end_date
          requested_days    = @employee.vacations[position].requested_days
          included_freedays = @employee.vacations[position].included_freedays
          period            = @employee.vacations[position].period
          date              = @employee.vacations[position].date

          had_change = false

          @employee.vacations.each_with_index do |vacation, index|
           
            if vacation.start_date.to_time > start_date.to_time

              @employee.vacations[position].start_date        = @employee.vacations[index].start_date
              @employee.vacations[position].end_date          = @employee.vacations[index].end_date
              @employee.vacations[position].requested_days    = @employee.vacations[index].requested_days
              @employee.vacations[position].included_freedays = @employee.vacations[index].included_freedays
              @employee.vacations[position].period            = @employee.vacations[index].period
              @employee.vacations[position].date              = @employee.vacations[index].date

              @employee.vacations[index].start_date        = start_date
              @employee.vacations[index].end_date          = end_date
              @employee.vacations[index].requested_days    = requested_days
              @employee.vacations[index].included_freedays = included_freedays
              @employee.vacations[index].period            = period
              @employee.vacations[index].date              = date

              had_change = true
              break
            end
          end
          unless had_change
            position += 1
          end
        end
        @employee.save
      end

      def sort_entries
        position = 0

        while position < @employee.entries.size
          
          start_date       = @employee.entries[position].start_date
          end_date         = @employee.entries[position].end_date
          reason_departure = @employee.entries[position].reason_departure
          document         = @employee.entries[position].document

          had_change = false

          @employee.entries.each_with_index do |entry, index|
           
            if entry.start_date.to_time > start_date.to_time

              @employee.entries[position].start_date       = @employee.entries[index].start_date
              @employee.entries[position].end_date         = @employee.entries[index].end_date
              @employee.entries[position].reason_departure = @employee.entries[index].reason_departure
              @employee.entries[position].document         = @employee.entries[index].document

              @employee.entries[index].start_date       = start_date
              @employee.entries[index].end_date         = end_date
              @employee.entries[index].reason_departure = reason_departure
              @employee.entries[index].document         = document

              had_change = true
              break
            end
          end
          unless had_change
            position += 1
          end
        end
        @employee.save
      end

      def sort_disabilities
        position = 0

        while position < @employee.disabilities.size
          
          start_date       = @employee.disabilities[position].start_date
          end_date         = @employee.disabilities[position].end_date

          had_change = false

          @employee.disabilities.each_with_index do |disability, index|
           
            if disability.start_date > start_date

              @employee.disabilities[position].start_date = @employee.disabilities[index].start_date
              @employee.disabilities[position].end_date   = @employee.disabilities[index].end_date

              @employee.disabilities[index].start_date    = start_date
              @employee.disabilities[index].end_date      = end_date

              had_change = true
              break
            end
          end
          unless had_change
            position += 1
          end
        end
        @employee.save
        @employee.disabilities.each do |disability|
          disability.start_date = disability.start_date.strftime("%d/%m/%Y")
          disability.end_date   = disability.end_date.strftime("%d/%m/%Y") if disability.end_date
        end
      end

      def sort_movements
        position = 0

        while position < @employee.movements.size
          
          start_date = @employee.movements[position].start_date
          end_date   = @employee.movements[position].end_date
          affair     = @employee.movements[position].affair
          way        = @employee.movements[position].way   
          amount     = @employee.movements[position].amount
          comment    = @employee.movements[position].comment

          had_change = false

          @employee.movements.each_with_index do |movement, index|
           
            if movement.start_date > start_date

              @employee.movements[position].start_date = @employee.movements[index].start_date
              @employee.movements[position].end_date   = @employee.movements[index].end_date
              @employee.movements[position].affair     = @employee.movements[index].affair
              @employee.movements[position].way        = @employee.movements[index].way     
              @employee.movements[position].amount     = @employee.movements[index].amount
              @employee.movements[position].comment    = @employee.movements[index].comment 

              @employee.movements[index].start_date = start_date
              @employee.movements[index].end_date   = end_date
              @employee.movements[index].affair     = affair
              @employee.movements[index].way        = way   
              @employee.movements[index].amount     = amount
              @employee.movements[index].comment    = comment

              had_change = true
              break
            end
          end
          unless had_change
            position += 1
          end
        end
        @employee.save
        @employee.movements.each do |movement|
          movement.start_date = movement.start_date.strftime("%d/%m/%Y")
          movement.end_date   = movement.end_date.strftime("%d/%m/%Y") if movement.end_date
        end
      end

      def update_christmas_bonuses(employee)
        from = Time.now.year
        to   = Time.now.year
        first_payrole_date = '30/11/2019'

        if employee.entries
          if employee.entries && employee.entries.last && employee.entries.last.start_date && employee.entries.last.start_date != "" && employee.entries.last.start_date.to_date.year >= 2020
            from = employee.entries.last.start_date.to_date.year
            first_payrole_date = employee.entries.last.start_date
          end
        end
        (from..to).each do |i|
          employee.calculate_christmas_bonification(i, first_payrole_date)
        end
      end
  end
end
