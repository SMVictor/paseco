class AddStatusToPositions < ActiveRecord::Migration[5.2]
  def change
    add_column :positions, :status, :string, default: "Activo"
  end
end
