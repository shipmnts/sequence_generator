class DropExtraColumnsFromSequence < ActiveRecord::Migration[5.2]
  def change
    remove_columns :sequence_generator_sequences,
      :sequence_prefix,
      :sequential_id,
      :start_at,
      :valid_from,
      :valid_till,
      :reset_from_next_year,
      :financial_year_start,
      :financial_year_end,
      :max_prefix_number
  end
end
