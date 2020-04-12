module Sequenced
  class Engine < ::Rails::Engine
    isolate_namespace Sequenced
    config.generators.api_only = true
  end
end
