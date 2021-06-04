class AddSortableDateToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :sortable_date, :date
  end
end
