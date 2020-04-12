module SequenceGenerator
  class Engine < ::Rails::Engine
    isolate_namespace SequenceGenerator
    config.generators.api_only = true
  end
end
