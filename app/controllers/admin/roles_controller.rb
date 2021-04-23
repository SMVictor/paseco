module Admin
class RolesController < ApplicationController

  layout 'admin', except: [:payrole_detail_pdf]

  load_and_authorize_resource
  before_action :set_role, only: [:show, :edit, :update, :destroy, :add_role_lines, :update_role_lines, :approvals, :check_changes, :stall_summary, :stalls_hours, :update_payrole_line]
  before_action :set_stall, only: [:update_role_lines, :add_role_lines, :check_changes, :stall_summary]
  before_action :set_payrole, only: [:show_payroles, :bncr_file, :bac_file, :payrole_detail, :budget, :old_budget, :budget_detail, :payrole_detail_pdf, :payrole_detail_email, :send_payslips]

  def index
    temporal_roles = Role.all
    @roles = []
    temporal_roles.each do |role|
      if @roles[0] == nil
        @roles << role
      else
        flat = true
        @roles.each_with_index do |listed_role, index|
          if role.start_date.to_date > listed_role.start_date.to_date
            @roles.insert(index, role)
            flat = false
            break
          end
        end
        if flat
          @roles << role
        end
      end
    end 
  end

  def show
  end

  def stall_summary
  end

  def new
    @role = Role.new
  end

  def edit
    @role.update(stall_ids: Stall.all.ids)
  end

  def create
    @role = Role.create(role_params)
    respond_to do |format|
      if @role.save
        format.html { redirect_to admin_roles_url, notice: 'El role se creó correctamente.' }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to admin_roles_url, notice: 'El role se actualizó correctamente.' }
        format.json { render json: @role, status: :ok, location: @role }
      else
        format.html { render :edit }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_role_lines
    if current_user.stalls.where(id: params[:stall_id]) != [] || current_user.admin?
      if (DateTime.parse(@role.end_date) + 5.days) > Date.today
        if params[:ajax] 
          @role.update(role_params)
        else
          @role.update(role_params)
          update_payrole_info(@role, Employee.find(params[:role][:employee_id]))
          load_budget if @stall.name.exclude?('Supervisor')
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to admin_role_lines_url, notice: 'El role se actualizó correctamente.' }
      format.json { render json: @role, status: :ok, location: @role }
    end 
  end

  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to admin_roles_url, notice: 'El role se eliminó correctamente.' }
    end
  end

  def add_role_lines

    if current_user.admin? || current_user.stalls.ids.include?(@stall.id)
      ids = []
      @role.role_lines.where(stall: @stall).each do |line|
        ids << line.employee.id
      end

      @stall.employees.where(active: true).each do |employee|
        ids << employee.id
      end

      ids.uniq

      @employees = Employee.where(id: ids)

      @substalls = []
      @count = 1
      while @count <= @stall.substalls.to_i
        @substalls[@count-1] = "Puesto " + @count.to_s
        @count = @count+1
      end

      @employee = Employee.find(params[:employee_id]) if params[:employee_id] != "0"  
      @role_lines = @role.role_lines.where(stall_id: @stall.id, employee: @employee).order(date: :asc)

      if params[:ajax]
        respond_to do |format|
          format.js
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_admin_role_path(@role) }
      end
    end
  end

  def approvals 
  end

  def index_payroles
    temporal_payroles = Role.all
    @payroles = []
    temporal_payroles.each do |payrole|
      if @payroles[0] == nil
        @payroles << payrole
      else
        flat = true
        @payroles.each_with_index do |listed_payrole, index|
          if payrole.start_date.to_date > listed_payrole.start_date.to_date
            @payroles.insert(index, payrole)
            flat = false
            break
          end
        end
        if flat
          @payroles << payrole
        end
      end
    end 
    @payrole =  Role.new
  end

  def show_payroles
    if params[:ids]
      @payrole_lines = @payrole.payrole_lines.where(id: params[:ids]).order(name: :asc)
    else
      @payrole_lines = @payrole.payrole_lines.order(name: :asc)
    end
    respond_to do |format|
      format.js
      format.html
      format.xls
    end

  end

  def bncr_file
   @bn_info = BncrInfo.first
   @total = 0
   @sumAccounts = @bn_info.account[8,6].to_i

   @payrole.payrole_lines.each do |payrole|
    if payrole.employee.bank == "BNCR" && payrole.employee.account != "" && payrole.net_salary.to_i > 0
      @total += payrole.net_salary.to_f
      @sumAccounts += payrole.employee.account[8,6].to_i
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

   @payrole.payrole_lines.each do |payrole|
    if payrole.employee.bank == "BAC" && payrole.employee.account != "" && payrole.employee.account != nil && payrole.net_salary.to_i > 0
      @total += payrole.net_salary.to_f
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

  def payrole_detail
    @employee = Employee.find(params[:employee_id])
    if current_user.admin? || current_user.human_resources? || current_user.psychologist? || current_user.identification == @employee.identification
      if (DateTime.parse(@role.end_date) + 5.days) > Date.today
        update_payrole_info(@role, @employee)
      end
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_payroles_path, notice: 'No posee permisos para ver la planilla solicitada.' }
      end
    end
  end

  def stalls_hours
    if params[:ids] && params[:ids] != ""
      @stalls = Stall.where(id: params[:ids])
    else
      @stalls = Stall.where(active: true).or(Stall.where(id: @role.role_lines.pluck("stall_id").uniq)).order(name: :asc)
    end

    if params[:ajax]
      respond_to do |format|
        format.js
      end
    end
  end

  def budget
    if params[:ids] && params[:ids] != ""
       @budgets = @payrole.budgets.where(stall_id: params[:ids])
    else
      @budgets = @payrole.budgets.order(id: :asc)
    end
    if params[:ajax]
      respond_to do |format|
        format.js
      end
    end
  end

   def budget_detail
    @employee = Employee.find(params[:employee_id])
  end


  def load_payrole
    respond_to do |format|
      if count = Role.import(params[:role][:file], params[:role][:name])
        format.html { redirect_to admin_payroles_path, notice: 'Se han cargado con éxito '+count.to_s+' registros.' }
      end
    end
  end

  def payrole_detail_pdf
    @employee = Employee.find(params[:employee_id])
    respond_to do |format|
      render layout: 'payrole_pdf'
      format.html
    end
  end

  def payrole_detail_email
    @employee = Employee.find(params[:employee_id])
    EmployeeMailer.send_payslip(@payrole, @employee).deliver_now
    respond_to do |format|
      format.html
    end
  end

  def send_payslips
    employees = Employee.where(active: true)
    employees.each do |employee|

      send_payslips = false
      stalls = employee.stalls
      stalls.each do |stall|
        send_payslips = stall.send_payslips
      end

      if send_payslips
        if employee.email != "" && employee.email != nil
          if PayroleDetail.where(payrole_id: @payrole.id, employee_id: employee.id)
            EmployeeMailer.send_payslip(@payrole, employee).deliver_later
          end 
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to admin_payroles_url, notice: 'Se han comenzado a enviar las boletas de pago.' }
    end
  end

  def update_payrole_line
    @role_line = RoleLine.find(params[:line_id])
    if (DateTime.parse(@role.end_date) + 5.days) > Date.today
      @role_line.update(role_line_params)
    end
    respond_to do |format|
      format.html { redirect_to admin_payrole_detail_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    def set_stall
      @stall = Stall.find(params[:stall_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payrole
      @payrole = Role.find(params[:id])
    end

    def update_payrole_info(role, employee)
      @role = role

      payrole_detail_id = 1
      @role_lines       = @role.role_lines.where(employee: employee).order(stall_id: :asc, date: :asc)
      payrole_detail    = employee.payrole_details.where(role_id: @role.id).first || employee.payrole_details.new(id: payrole_detail_id+1, role: @role)
      detail_line_id    = 1
      has_night         =  @role_lines.joins(:shift).where("name = 'Noche'").length

       payrole_detail.detail_lines.where(role_line_id: nil).destroy_all

      @total_day_salary     = 0 
      @total_extra_hours    = 0 
      @total_extra_salary   = 0 
      @total_extra_payments = 0 
      @total_deductions     = 0 
      @total_viatical       = 0
      @total_holidays       = 0

      @role_lines.each do |line|

        employee.calculate_daily_viatical(line)
        employee.calculate_day_salary(line, has_night)

        @total_day_salary     += employee.day_salary
        @total_extra_hours    += employee.extra_day_hours 
        @total_extra_salary   += employee.extra_day_salary 
        @total_extra_payments += line.extra_payments.to_f 
        @total_deductions     += line.deductions.to_f 
        @total_viatical       += employee.viatical
        @total_holidays       += employee.holiday

        detail_line = line.detail_line || payrole_detail.detail_lines.new(id: detail_line_id+1, role_line: line, stall: line.stall, shift:line.shift)
        detail_line.date                 = line.date
        detail_line.shift_name           = line.shift.name
        detail_line.stall_name           = line.stall.name
        detail_line.substall             = line.substall
        detail_line.hours                = employee.normal_day_hours
        detail_line.salary               = employee.day_salary.round(2)
        detail_line.holiday              = employee.holiday.round(2)
        detail_line.extra_hours          = employee.extra_day_hours.round(2)
        detail_line.extra_salary         = employee.extra_day_salary.round(2)
        detail_line.viatical             = employee.viatical.round(2)
        detail_line.extra_payment        = line.extra_payments
        detail_line.extra_payment_reason = line.extra_payments_description
        detail_line.deductions           = line.deductions
        detail_line.deductions_reason    = line.deductions_description
        detail_line.comments             = line.comment
        detail_line.employee_name        = payrole_detail.employee.name
        detail_line.sector               = line.stall.customer.sector.name
        detail_line.service              = line.sub_service.service.name
        detail_line.sub_service          = line.sub_service.name
        detail_line.stall_type           = line.stall.type.name

        detail_line_id += 1
        detail_line.save

      end
      employee.calculate_payment(@role_lines.length, @total_day_salary, @total_extra_hours, @total_extra_salary, @total_viatical, @total_extra_payments, @total_deductions, @total_holidays)
      employee.add_automatic_movements(role)

      @payrole_line = @role.payrole_lines.where(employee: employee)[0] || @role.payrole_lines.new([{ min_salary: '0', extra_hours: '0', daily_viatical: '0', ccss_deduction: '0', extra_payments: '0', deductions: '0', net_salary: '0', employee_id: employee.id }])[0]

      @payrole_line.num_worked_days = employee.total_days
      @payrole_line.min_salary      = employee.total_day_salary.round(2)
      @payrole_line.num_extra_hours = employee.total_extra_hours
      @payrole_line.extra_hours     = employee.total_extra_salary.round(2)
      @payrole_line.daily_viatical  = employee.total_viatical.round(2)
      @payrole_line.ccss_deduction  = employee.ccss_deduction.round(2)
      @payrole_line.net_salary      = employee.net_salary.round(2)
      @payrole_line.extra_payments  = employee.total_exta_payments.round(2)
      @payrole_line.deductions      = employee.total_deductions.round(2)
      @payrole_line.holidays        = employee.total_holidays.round(2)
      @payrole_line.name            = employee.name
      @payrole_line.bank            = employee.bank
      @payrole_line.ccss_type       = employee.ccss_type == 'yes'? 'Completo' : 'Normal'
      @payrole_line.social_security = employee.social_security
      @payrole_line.account         = employee.account

      payrole_detail.worked_days    = employee.total_days
      payrole_detail.base_salary    = (employee.total_day_salary + employee.total_holidays).round(2)
      payrole_detail.extra_hours    = employee.total_extra_hours.round(2)
      payrole_detail.extra_salary   = employee.total_extra_salary.round(2)
      payrole_detail.viatical       = employee.total_viatical.round(2)
      payrole_detail.extra_payments = employee.total_exta_payments.round(2) 
      payrole_detail.deductions     = employee.total_deductions.round(2)
      payrole_detail.gross_salary   = (employee.total_day_salary + employee.total_holidays + employee.total_extra_salary + employee.total_viatical + employee.total_exta_payments).round(2)
      payrole_detail.ccss_deduction = employee.ccss_deduction.round(2) 
      payrole_detail.net_salary     = employee.net_salary.round(2)

      @payrole_line.save
      payrole_detail.save

    end

    def load_budget
      budget_stall = if @role.budgets.where(stall: @stall) != [] then @role.budgets.where(stall: @stall).first else Budget.create(role: @role, stall: @stall) end
      
      detail_lines = DetailLine.joins(:payrole_detail).where('payrole_details.role_id= ?', @role.id).where('detail_lines.stall_id = ?', @stall.id)
      detail_lines.where(salary: '').update_all(salary: '0')
      detail_lines.where(holiday: '').update_all(holiday: '0')
      detail_lines.where(extra_salary: '').update_all(extra_salary: '0')
      detail_lines.where(viatical: '').update_all(viatical: '0')
      detail_lines.where(extra_payment: '').update_all(extra_payment: '0')
      detail_lines.where(deductions: '').update_all(deductions: '0')
      detail_lines_join = detail_lines.select('SUM(CAST(detail_lines.salary AS FLOAT)) AS salary', 'SUM(CAST(detail_lines.holiday AS FLOAT)) AS holiday', 'SUM(CAST(detail_lines.extra_salary AS FLOAT)) AS extra_salary', 'SUM(CAST(detail_lines.viatical AS FLOAT)) AS viatical', 'SUM(CAST(detail_lines.extra_payment AS FLOAT)) AS extra_payment', 'SUM(CAST(detail_lines.deductions AS FLOAT)) AS deductions', 'employee_name', 'payrole_detail_id').group(:employee_name, :payrole_detail_id)

      total_stall = 0
      detail_lines_join.each do |line|
        budget_line = if budget_stall.budget_lines.where(employee_id: line.payrole_detail.employee_id) != [] then budget_stall.budget_lines.where(employee_id: line.payrole_detail.employee_id).first else BudgetLine.create(employee: line.payrole_detail.employee, budget: budget_stall) end
        budget_line.salary = line.salary.to_f + line.holiday.to_f + line.extra_salary.to_f + line.viatical.to_f + line.extra_payment.to_f - line.deductions.to_f
        budget_line.save

        total_stall += (line.salary.to_f + line.holiday.to_f + line.extra_salary.to_f + line.viatical.to_f + line.extra_payment.to_f - line.deductions.to_f)
      end
      budget_stall.total_stall = total_stall

      quote     = @stall.quote 
      salary    = quote.daily_salary.to_f 
      vacations = quote.vacations.to_f 
      holidays  = quote.holidays.to_f 
      budget = 0

      @stall.quote.requirements.each do |requirement| 

        salary = quote.daily_salary.to_f 

        if quote.night_salary != "" && (requirement.shift.name.upcase.include? "NOCHE")  
          salary = quote.night_salary.to_f 
        end 

        if requirement.position.salary != "" && requirement.position.salary != "0" && requirement.position.salary != nil 
          salary = requirement.position.salary.to_f 
        end 

        required_hours = requirement.hours.to_f 
        shift_hours    = requirement.shift.time.to_f 
        shift_hours    = requirement.position.hours.to_f if (requirement.position.hours != nil && requirement.position.hours != "") 
        extra_hours    = 0 
        extra_hours    = required_hours - shift_hours if required_hours > shift_hours 
        normal_hours   = required_hours - extra_hours 
        day_salary     = salary/30 
        hour_salary    = day_salary/shift_hours 
        extra_salary   = hour_salary*requirement.shift.extra_time_cost.to_f 

        budget += (((normal_hours * hour_salary) + (extra_hours * extra_salary))*15*requirement.workers.to_f*(1+requirement.freeday_worker.to_f)) 
      end 

      total = (budget + (holidays/2) + (vacations/2)).round(2)

      budget_stall.salary         = budget.round(2) 
      budget_stall.vacations      = (vacations/2).round(2) 
      budget_stall.holidays       = (holidays/2).round(2) 
      budget_stall.total_budget   = total 
      budget_stall.difference     = (total - total_stall).round(2) 
      budget_stall.social_charges = (total*0.4307).round(2) 
      budget_stall.cs_difference  = ((total*0.4307) - (total_stall*0.4307)).round(2) 

      budget_stall.save 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:name, :start_date, :end_date, stall_ids: [], role_lines_attributes: [:id, :date, :start_date, :start_hour, :end_date, :end_hour, :employee_id, :stall_id, :shift_id, :substall, :comment, :hours, :requirement_justification, :extra_payments, :extra_payments_description, :deductions, :deductions_description, :holiday, :position_id, :sub_service_id, :user_email, :_destroy])
    end

    def role_line_params
      params.require(:role_line).permit(:date, :shift_id, :substall, :position_id, :sub_service_id, :hours, :comment, :requirement_justification, :extra_payments, :extra_payments_description, :deductions, :deductions_description )
    end
  end
end
