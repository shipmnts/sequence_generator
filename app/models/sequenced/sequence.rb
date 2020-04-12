module Sequenced
  class Sequence < ApplicationRecord
    validates_presence_of :name, :scope, :purpose
    validates_uniqueness_of :name, scope: [:scope, :purpose]
  end
end
