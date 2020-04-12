module SequenceGenerator
  class CurrentSequence < ApplicationRecord
    validates_presence_of :name, :current, :scope
    validates_uniqueness_of :name, scope: :scope

    def self.get_next_number(prefix, scope)
      current_sequence = CurrentSequence.lock.where(name: prefix, scope: scope).first
      if current_sequence
        current_sequence.update!(current: current_sequence.current + 1)
      else
        current_sequence = CurrentSequence.create!(name: prefix, scope: scope, current: 1)
      end
      current_sequence.current
    end
  end
end
