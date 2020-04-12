class SomeModel < ApplicationRecord
  acts_as_sequence_generator purpose: 'test', scope: 'tenant_id', column: 'name'
end
