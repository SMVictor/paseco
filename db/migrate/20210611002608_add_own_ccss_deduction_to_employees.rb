class AddOwnCcssDeductionToEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :own_ccss_deduction, :float
  end
end
