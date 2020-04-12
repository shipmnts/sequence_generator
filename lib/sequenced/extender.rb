module Sequenced
  module Extender

    def acts_as_sequenced(options = {})
      include Sequenced::Generator

      [:purpose, :scope, :column].each do |option|
        raise StandardError.new("#{option} option needs to be provided to acts_as_sequenced") unless options[option].present?
      end

      options[:validation_options] ||= {on: :create}
      options[:validation_options][:on] ||= :create
      before_validation options[:validation_options] do
        generate_sequence(options)
      end
    end
  end

  module Generator
    def self.included(base)
      def generate_sequence(options)
        return if send(options[:column]).present?
        sequence = Sequence.find_by!(purpose: options[:purpose], scope: send(options[:scope]))
        assign_attributes(options[:column]=> sequence.generate_next(options, self))
      end
    end
  end
end


## Tests  to be written ##

# Same model multiple sequence
# validation options... on create, update
# current sequence missing
# current sequence there
# No # in the sequence
# Method not defined in the sequence
# Basic: always generates just +1
# Model validations
# options like YY MM etc
# simulate locking