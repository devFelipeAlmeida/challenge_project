module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      # before_action :check_admin, only: [:index, :show] # Adicione a ação show ao filtro admin

      # GET /api/v1/users
      def index
        users = User.all
        render json: users, status: :ok
      end

      # GET /api/v1/users/:id
      def show
        user = User.find_by(id: params[:id])
        if user
          render json: user, status: :ok
        else
          render json: { error: 'User not found' }, status: :not_found
        end
      end

      private

      def check_admin
        unless current_user.admin?
          render json: { error: 'Access denied' }, status: :forbidden
        end
      end
    end
  end
end