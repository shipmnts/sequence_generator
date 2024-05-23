module SequenceGenerator
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
        when "IFYY"
          financial_year_start_date = DateTime.new(date_to_consider.year, 4, 1, 0, 0, 0, Rational(5.5,24))
          if date_to_consider > financial_year_start_date
            "#{date_to_consider.strftime('%y')}-#{date_to_consider.next_year.strftime('%y')}"
          else
            "#{date_to_consider.prev_year.strftime('%y')}-#{date_to_consider.strftime('%y')}"
          end
        when "IFY"
          financial_year_start_date = DateTime.new(date_to_consider.year, 4, 1, 0, 0, 0, Rational(5.5,24))
          if date_to_consider > financial_year_start_date
            "#{date_to_consider.strftime('%y')}#{date_to_consider.next_year.strftime('%y')}"
          else
            "#{date_to_consider.prev_year.strftime('%y')}#{date_to_consider.strftime('%y')}"
          end
        when "MM"
          date_to_consider.strftime('%m')
        else
          model.send(fragment)
        end
      end

      prefix = !prefix[/#+/] ? prefix + "#####" : prefix
      digits = prefix[/#+/].length
      prefix_without_digits, suffix = prefix.split(/#+/)
      next_number = CurrentSequence.get_next_number(prefix_without_digits, scope, purpose)
      sequence_number = "%0#{digits}d" % (next_number).to_s
      prefix_without_digits + sequence_number + (suffix || '')
    end
  end
end
