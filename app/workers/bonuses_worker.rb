class BonusesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
  	employees = Employee.where(active: true)
  	employees.each do |employee|
  	  update_christmas_bonuses(employee)
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
end