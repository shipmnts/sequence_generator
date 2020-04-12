class CreateSomeModels < ActiveRecord::Migration[6.0]
  def change
    create_table :some_models do |t|
      t.string :name
      t.integer :tenant_id

      t.timestamps
    end
  end
end
