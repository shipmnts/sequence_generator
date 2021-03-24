module SequenceGenerator
  class CurrentSequence < ApplicationRecord
    validates_presence_of :name, :current, :scope, :purpose
    validates_uniqueness_of :name, scope: [:scope, :purpose]

    def self.get_next_number(prefix, scope, purpose)
      current_sequence = CurrentSequence.lock.where(name: prefix, scope: scope, purpose: purpose).first
      if current_sequence
        current_sequence.update!(current: current_sequence.current + 1)
      else
        current_sequence = CurrentSequence.create!(name: prefix, scope: scope, purpose: purpose, current: 1)
      end
      current_sequence.current
    end
  end
end
