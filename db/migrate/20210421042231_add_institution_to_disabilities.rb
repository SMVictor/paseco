class AddInstitutionToDisabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :disabilities, :institution, :string
  end
end
