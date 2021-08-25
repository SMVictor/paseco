class BonusesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
  	employees = Employee.where(active: true)
  	employees.each do |employee|
  	  update_christmas_bonuses(employee)
      role = Role.order(id).last
      if (DateTime.parse(role.end_date) + 5.days) > Date.today
        update_payrole_info(role, employee)
      end
  	end
  end

  def update_christmas_bonuses(employee)
    if employee.has_christmas_bonus
      @employee = employee

      from = Time.now.year
      to   = Time.now.year
      first_payrole_date = '30/11/2019'

      if @employee.entries
        if @employee.entries && @employee.entries.order(:sortable_date).last && @employee.entries.order(:sortable_date).last.start_date && @employee.entries.order(:sortable_date).last.start_date != "" && @employee.entries.order(:sortable_date).last.start_date.to_date.year >= 2020
          from = @employee.entries.order(:sortable_date).last.start_date.to_date.year
          first_payrole_date = @employee.entries.order(:sortable_date).last.start_date
        end
      end
      (from..to).each do |i|
        @employee.calculate_christmas_bonification(i, first_payrole_date)
      end
    end
  end

  def update_payrole_info(role, employee)
    @role = role

    payrole_detail_id = PayroleDetail.all.order(id: :asc).last.id
    @role_lines       = @role.role_lines.where(employee: employee).order(stall_id: :asc, date: :asc)
    payrole_detail    = employee.payrole_details.where(role_id: @role.id).first || employee.payrole_details.new(id: payrole_detail_id+1, role: @role)
    detail_line_id    = DetailLine.all.order(id: :asc).last.id
    has_night         =  @role_lines.joins(:shift).where("name = 'Noche'").length

     payrole_detail.detail_lines.where(role_line_id: nil).destroy_all

    @total_day_salary     = 0 
    @total_extra_hours    = 0 
    @total_extra_salary   = 0 
    @total_extra_payments = 0 
    @total_deductions     = 0 
    @total_viatical       = 0
    @total_holidays       = 0

    #Para los casos que tienen deducción de la caja diferenciada
    @total_ccss_day_salary   = 0
    @total_ccss_extra_salary = 0
    @total_ccss_viatical     = 0
    @total_ccss_holidays     = 0

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
      detail_line.stall_id             = line.stall.id
      detail_line.shift_id             = line.shift.id

      #Para los casos que tienen deducción de la caja diferenciada
      if employee.own_ccss_deduction != nil && employee.own_ccss_deduction > 0

        @total_ccss_viatical     += employee.viatical

        employee.calculate_day_salary_with_min_salary(line, employee.own_ccss_deduction)

        @total_ccss_day_salary   += employee.day_salary
        @total_ccss_extra_salary += employee.extra_day_salary
        @total_ccss_holidays     += employee.holiday
        
      end

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
    payrole_detail.holidays       = (employee.total_holidays).round(2)
    payrole_detail.extra_hours    = employee.total_extra_hours.round(2)
    payrole_detail.extra_salary   = employee.total_extra_salary.round(2)
    payrole_detail.viatical       = employee.total_viatical.round(2)
    payrole_detail.extra_payments = employee.total_exta_payments.round(2) 
    payrole_detail.deductions     = employee.total_deductions.round(2)
    payrole_detail.gross_salary   = (employee.total_day_salary + employee.total_holidays + employee.total_extra_salary + employee.total_viatical + employee.total_exta_payments).round(2)
    payrole_detail.ccss_deduction = employee.ccss_deduction.round(2) 
    payrole_detail.net_salary     = employee.net_salary.round(2)

    #Para los casos que tienen deducción de la caja diferenciada
    if employee.own_ccss_deduction != nil && employee.own_ccss_deduction > 0

      old_gross_salary = employee.net_salary + employee.ccss_deduction

      employee.calculate_payment(@role_lines.length, @total_ccss_day_salary, @total_extra_hours, @total_ccss_extra_salary, @total_ccss_viatical, @total_extra_payments, @total_deductions, @total_ccss_holidays)
      
      @payrole_line.ccss_deduction  = employee.ccss_deduction.round(2)
      @payrole_line.net_salary      = (old_gross_salary - employee.ccss_deduction).round(2)
      payrole_detail.ccss_deduction = employee.ccss_deduction.round(2)
      payrole_detail.net_salary     = (old_gross_salary - employee.ccss_deduction).round(2)

    end

    @payrole_line.save
    payrole_detail.save

  end
end