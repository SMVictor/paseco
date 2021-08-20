class AddHolidaysToPayroleDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :payrole_details, :holidays, :float, default: 0
  end
end
