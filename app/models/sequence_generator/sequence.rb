module SequenceGenerator
  class Sequence < ApplicationRecord
    validates_presence_of :name, :scope, :purpose
    validates_uniqueness_of :name, scope: [:scope, :purpose]

    def generate_next(options, model)
      date_to_consider = Time.now
      if options[:date_column] && model.send(options[:date_column])
        date_to_consider = model.send(options[:date_column])
      end

      prefix = name.gsub(/[\(\{][^(){}]*?[\)\}]/) do |x|
        fragment = x[1..-2] # strip () or {}
        resolve_fragment(fragment, model, date_to_consider)
      end

      # Build sequence-driving prefix (only () fields)
      sequence_prefix = name.gsub(/[\(\{][^(){}]*?[\)\}]/) do |x|
        fragment = x[1..-2]
        if x.start_with?("(")
          resolve_fragment(fragment, model, date_to_consider)
        else
          ""
        end
      end


      # Handle numeric padding
      prefix = !prefix[/#+/] ? prefix + "#####" : prefix
      digits = prefix[/#+/].length
      prefix_without_digits, suffix = prefix.split(/#+/)
      sequence_prefix_without_digits, sequence_suffix = sequence_prefix.split(/#+/)

      # Use only sequence-driving prefix for lookup
      if options[:override_sequence_number].present?
        sequence_number = options[:override_sequence_number]
      else
        next_number = CurrentSequence.get_next_number(sequence_prefix_without_digits, scope, purpose)
        sequence_number = "%0#{digits}d" % (next_number).to_s
      end
      prefix_without_digits + sequence_number + (suffix || '')
    end

    def resolve_fragment(fragment, model, date_to_consider)
      case fragment
      when "YYYY"
        date_to_consider.strftime('%Y')
      when "YY"
        date_to_consider.strftime('%y')
      when "IFYY"
        fy_start = DateTime.new(date_to_consider.year, 4, 1, 0, 0, 0, Rational(5.5,24))
        if date_to_consider > fy_start
          "#{date_to_consider.strftime('%y')}-#{date_to_consider.next_year.strftime('%y')}"
        else
          "#{date_to_consider.prev_year.strftime('%y')}-#{date_to_consider.strftime('%y')}"
        end
      when "IFY"
        fy_start = DateTime.new(date_to_consider.year, 4, 1, 0, 0, 0, Rational(5.5,24))
        if date_to_consider > fy_start
          "#{date_to_consider.strftime('%y')}#{date_to_consider.next_year.strftime('%y')}"
        else
          "#{date_to_consider.prev_year.strftime('%y')}#{date_to_consider.strftime('%y')}"
        end
      when "MM"
        date_to_consider.strftime('%m')
      when "/"
        "/"
      else
        model.send(fragment)
      end
    end
  end
end
