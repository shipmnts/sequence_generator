Rails.application.routes.draw do
  mount Sequenced::Engine => "/sequenced"
end
