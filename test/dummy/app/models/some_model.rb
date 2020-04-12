class SomeModel < ApplicationRecord
  acts_as_sequenced purpose: 'test', scope: 'tenant_id', column: 'name'
end
