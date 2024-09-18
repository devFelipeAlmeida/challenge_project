module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_challenge

      def index
        comments = @challenge.comments.includes(:user) # Inclui informações do usuário para otimizar a consulta
        render json: comments, include: ['user'], status: :ok
      end

      # POST /api/v1/challenges/:challenge_id/comments
      def create
        comment = @challenge.comments.new(comment_params)
        comment.user = current_user

        if comment.save
          # Enviar notificação para o administrador
          admin = User.find_by(email: ENV['ADMIN_EMAIL'])
          if admin
            Notification.create!(
              recipient: admin,
              challenge: @challenge,
              message: "Comentário do usuário #{current_user.email}: '#{comment.content}' para o desafio '#{@challenge.title}'.",
              notification_type: "challenge_comment",
              read: false
            )
          end
          render json: { message: "Comment added successfully", data: comment }, status: :created
        else
          render json: { message: "Failed to add comment", errors: comment.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_challenge
        @challenge = Challenge.find(params[:challenge_id])
        render json: { message: "Challenge not found" }, status: :not_found unless @challenge
      end

      def comment_params
        params.require(:comment).permit(:content)
      end
    end
  end
end