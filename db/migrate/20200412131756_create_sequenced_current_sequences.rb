class CreateSequencedCurrentSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :sequenced_current_sequences do |t|
      t.string :name
      t.column :current, :integer, default: 1
      t.string :scope

      t.timestamps
    end
  end
end
