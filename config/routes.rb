Sequenced::Engine.routes.draw do
  resources :sequences, only: [:create, :get, :index]
end
