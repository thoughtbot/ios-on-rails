Humon::Application.routes.draw do
  scope module: :api, defaults: { format: 'json' } do
    namespace :v1 do
      namespace :events do
        resource :nearest, only: [:show]
      end

      resources :attendances, only: [:create]
      resources :events, only: [:create, :show, :update]
      resources :users, only: [:create]
    end
  end
end
