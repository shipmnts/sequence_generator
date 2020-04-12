module Sequenced
  class CurrentSequence < ApplicationRecord
    validates_presence_of :name, :current, :scope
    validates_uniqueness_of :name, scope: :scope
  end
end
