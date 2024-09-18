Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  namespace :api do
    namespace :v1 do
      resources :challenges do
        collection do
          get :active_and_upcoming # Rota para listar desafios ativos e futuros
          get :completed_challenges # Rota para listar desafios concluídos (acessível apenas para admin)
        end

        member do
          patch :mark_as_completed # Rota para marcar um desafio como concluído
          delete :approve # Rota para aprovar um desafio concluído
          patch :reject # Rota para rejeitar um desafio concluído
        end

        # Adiciona as rotas de comentários dentro de cada desafio
        resources :comments, only: [:index, :create]
      end

      resources :users, only: [:index, :show] # Adiciona a rota GET /api/v1/users

      # Adiciona as rotas para as notificações
      resources :notifications, only: [:index] do
        member do
          delete :mark_as_read # Rota para marcar uma notificação como lida e deletá-la
        end
      end
    end
  end
end