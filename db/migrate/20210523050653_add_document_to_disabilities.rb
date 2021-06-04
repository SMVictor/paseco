class AddDocumentToDisabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :disabilities, :document, :string
  end
end
