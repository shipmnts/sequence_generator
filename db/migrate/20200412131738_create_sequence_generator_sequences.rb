class CreateSequenceGeneratorSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :sequence_generator_sequences do |t|
      t.string :name, null: false
      t.string :scope, null: false
      t.string :purpose, null: false

      t.timestamps
    end
  end
end
