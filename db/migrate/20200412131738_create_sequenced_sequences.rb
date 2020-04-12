class CreateSequencedSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :sequenced_sequences do |t|
      t.string :name
      t.string :scope
      t.string :purpose

      t.timestamps
    end
  end
end
