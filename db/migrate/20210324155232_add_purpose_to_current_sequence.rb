class AddPurposeToCurrentSequence < ActiveRecord::Migration[5.2]
  def change
    add_column :sequence_generator_current_sequences, :purpose, :string
    SequenceGenerator::Sequence.all.map do |sequence|
      current_sequences = SequenceGenerator::CurrentSequence.where(scope: sequence.scope)
      prefix = sequence.name.gsub(/\([^()]*?\)/) do |x|
        fragment = x[1..-2]
        case fragment
        when "YYYY"
          '(2022|2021|2020|2019|2018)'
        when "YY"
          '(22|21|20|19|18)'
        when "IFYY"
          '(21-22|20-21|19-20|18-19|17-18)'
        when "IFY"
          '(2122|2021|1920|1819|1718)'
        when "MM"
          '(01|02|03|04|05|06|07|08|09|10|11|12)'
        else
          '.{1,4}'
        end
      end
      prefix = prefix.gsub('#','')
      prefix = prefix + '$'

      current_sequences.map do |current_sequence|
        next if current_sequence.purpose
        if current_sequence.name.match Regexp.new(prefix)
          current_sequence.purpose = sequence.purpose
          current_sequence.save!
        end
      end
    end
  end
end
