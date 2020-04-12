require "sequenced/engine"

module Sequenced
  if defined?(ActiveRecord::Base)
    require "sequenced/extender"
    ActiveRecord::Base.extend Sequenced::Extender
  end
end
