module Sequenced
  class Sequence < ApplicationRecord
    validates_presence_of :name, :scope, :purpose
    validates_uniqueness_of :name, scope: [:scope, :purpose]

    def generate_next(options, model)
      date_to_consider = Time.now
      if options[:date_column] && model.send(options[:date_column])
        date_to_consider = model.send(options[:date_column])
      end

      prefix = name.gsub(/\([^()]*?\)/) do |x|
        fragment = x[1..-2]
        case fragment
        when "YYYY"
          date_to_consider.strftime('%Y')
        when "YY"
          date_to_consider.strftime('%y')
        when "NYYY"
          date_to_consider.next_year.strftime('%Y')
        when "NY"
          date_to_consider.next_year.strftime('%y')
        when "MM"
          date_to_consider.strftime('%m')
        else
          model.send(fragment)
        end
      end

      prefix = prefix[/#*$/] == "" ? prefix + "#####" : prefix
      digits = prefix[/#*$/].length
      prefix_without_digits = prefix.split(/#*$/)[0]
      next_number = CurrentSequence.get_next_number(prefix_without_digits, scope)
      sequence_number = "%0#{digits}d" % (next_number).to_s
      prefix_without_digits + sequence_number
    end
  end
end
