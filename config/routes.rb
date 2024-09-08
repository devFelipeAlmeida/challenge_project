Rails.application.routes.draw do
  devise_for :users, controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations'
      }
  namespace :api do
    namespace :v1 do
      resources :challenges do
        collection do
          get :active_and_upcoming
        end
      end
    end
  end
end
