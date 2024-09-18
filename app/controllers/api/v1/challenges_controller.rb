module Api
  module V1
    class ChallengesController < ApplicationController
      before_action :authenticate_user!, only: %i[create update destroy mark_as_completed reject approve]
      before_action :set_challenge, only: %i[show update destroy mark_as_completed  approve]
      before_action :authorize_admin, only: %i[create update destroy completed_challenges reject approve]

      # GET api/v1/challenges
      def index
        @challenges = Challenge.all
        render json: { message: "Challenges retrieved successfully", data: @challenges }
      end

      def active_and_upcoming
        if current_user
          @active_challenges = current_user.challenges.active
          @upcoming_challenges = current_user.challenges.upcoming
          render json: { active: @active_challenges, upcoming: @upcoming_challenges }
        else
          render json: { message: "User not authenticated" }, status: :unauthorized
        end
      end

      # GET api/v1/challenges/completed_challenges
      def completed_challenges
        @completed_challenges = Challenge.where(status: 'completed')
        render json: { message: "Completed challenges retrieved successfully", data: @completed_challenges }
      end

      def approve
        @challenge = Challenge.find_by(id: params[:id])
        
        if @challenge.update(status: 'approved')
          Notification.create(
            recipient: User.find(@challenge.user_id),
            challenge: @challenge,
            message: "Seu desafio '#{@challenge.title}' foi aprovado.",
            notification_type: "challenge_approved",
            read: false
          )
      
          
          if @challenge.destroy
            render json: { message: "Challenge approved and deleted successfully." }
          else
            render json: { message: "Failed to delete challenge.", errors: @challenge.errors }, status: :unprocessable_entity
          end
      
          render json: { message: "Challenge approved. Check if notification was created." }
        else
          render json: { message: "Failed to approve challenge.", errors: @challenge.errors }, status: :unprocessable_entity
        end
      end
      
      # POST api/v1/challenges/:id/reject
      def reject
        @challenge = Challenge.find_by(id: params[:id])
        if @challenge.nil?
          render json: { error: "Challenge not found." }, status: :not_found
        else
          @challenge.update(status: 'active') # Atualiza o status do desafio
          Notification.create(
            recipient: User.find(@challenge.user_id),
            challenge: @challenge,
            message: "Seu desafio '#{@challenge.title}' foi rejeitado e está de volta ao status 'ativo'.",
            notification_type: "challenge_rejected",
            read: false
          )
          render json: { message: "Challenge rejected successfully." }
        end
      end

      # POST api/v1/challenges
      def create
        user = User.find_by(id: challenges_params[:user_id])
        if user.nil?
          render json: { message: "Invalid user ID" }, status: :unprocessable_entity
          return
        end

        @challenge = Challenge.new(challenges_params.merge(user_id: user.id))
        if @challenge.save
          # Cria uma notificação para o usuário
          Notification.create(
            recipient: user,
            challenge: @challenge,
            message: "Um novo desafio foi criado para você: #{@challenge.title}",
            notification_type: "new_challenge",
            read: false
          )
          render json: { message: "Challenge added successfully", data: @challenge }, status: :created
        else
          render json: { message: "Failed to add challenge", data: @challenge.errors }, status: :unprocessable_entity
        end
      end 

      # GET api/v1/challenges/:id
      def show
        if @challenge
          render json: { message: "Challenge found", data: @challenge }
        else
          render json: { message: "Challenge not found", data: @challenge.errors }
        end
      end

      def update
        if @challenge.update(challenges_params)
          render json: { message: "Challenge updated successfully", data: @challenge }
        else
          render json: { message: "Failed to update challenge", data: @challenge.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @challenge.destroy
          render json: { message: "Challenge deleted successfully", data: @challenge }
        else
          render json: { message: "Failed to delete challenge", data: @challenge.errors }, status: :unprocessable_entity
        end
      end

      def mark_as_completed
        comment_content = params[:comment] # Obtém o comentário do usuário a partir dos parâmetros (pode ser nulo ou vazio)
      
        ActiveRecord::Base.transaction do
          # Marca o desafio como concluído
          @challenge.update!(status: 'completed')
      
          # Cria o comentário apenas se houver conteúdo
          if comment_content.present?
            Comment.create!(challenge: @challenge, user: current_user, content: comment_content)
          end

          # Cria notificação para o admin
          admin = User.find_by(admin: true) # Busca um usuário com admin: true
          if admin
            Notification.create!(
              recipient: admin,
              challenge: @challenge,
              message: comment_content.present? ?
                "O desafio '#{@challenge.title}' foi concluído pelo usuário #{current_user.email} com o comentário: '#{comment_content}'." :
                "O desafio '#{@challenge.title}' foi concluído pelo usuário #{current_user.email}.",
              notification_type: "challenge_completed",
              read: false
            )
          end
        end
      
        render json: { message: "Challenge marked as completed successfully.", data: { challenge: @challenge, comment: comment_content } }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { message: "Failed to mark challenge as completed.", errors: e.record.errors }, status: :unprocessable_entity
      end

      private

      def authorize_admin
        unless current_user.admin?
          render json: { message: "Forbidden action" }, status: :unauthorized
        end
      end

      def set_challenge
        @challenge = Challenge.find(params[:id])
        render json: { message: "Challenge not found" }, status: :not_found unless @challenge
      end

      def challenges_params
        params.require(:challenge).permit(:title, :description, :start_date, :end_date, :user_id)
      end
    end
  end
end