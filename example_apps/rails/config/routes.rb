Humon::Application.routes.draw do
  scope module: :api, defaults: { format: 'json' } do
    namespace :v1 do
      namespace :events do
        resources :nearests, only: [:index]
      end

      resources :attendances, only: [:create]
      resources :events, only: [:create, :show, :update]
      resources :users, only: [:create]
    end
  end
end
