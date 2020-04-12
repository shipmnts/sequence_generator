class AddNameToSequence < ActiveRecord::Migration[5.2]
  def change
    add_column :sequence_generator_sequences, :name, :string
  end
end
