Rails.application.routes.draw do
  root 'pages#index'

  resources :pages do
    collection do
      get :index
      post :chat
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
