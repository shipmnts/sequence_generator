class CreateSequencedCurrentSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :sequenced_current_sequences do |t|
      t.string :name, null: false
      t.column :current, :integer, default: 1, null: false
      t.string :scope, null: false

      t.timestamps
    end
  end
end
