require "sequence_generator/engine"

module SequenceGenerator
  if defined?(ActiveRecord::Base)
    require "sequence_generator/extender"
    ActiveRecord::Base.extend SequenceGenerator::Extender
  end
end
