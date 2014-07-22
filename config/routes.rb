Rails.application.routes.draw do
  root 'things#index'

  resources :things do
    collection do
      get :search
    end
  end
end