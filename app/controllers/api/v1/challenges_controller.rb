module Api
  module V1
    class ChallengesController < ApplicationController
      before_action :authenticate_user!, only: %i[create update destroy]
      before_action :set_challenge, only: %i[show update destroy]
      before_action :authorize_admin, only: %i[create update destroy]

      # GET api/v1/challenges
      def index
        @challenges = Challenge.all
        render json: { message: "Challenges retrieved successfully", data: @challenges }
      end

      def active_and_upcoming
        @active_challenges = Challenge.active
        @upcoming_challenges = Challenge.upcoming
        render json: { active: @active_challenges, upcoming: @upcoming_challenges }
      end

      # POST api/v1/challenges
      def create
        # @challenge = Challenge.new(challenges_params.merge(user_id: current_user.id))
        @challenge = current_user.challenges.build(challenges_params)
        if @challenge.save
          render json: { message: "Challenge added successfully", data: @challenge }, status: :created
        else
          render json: { message: "Failed to add challenge", data: @challenge.errors }, status: :unprocessable_entity
        end
      end

      # POST api/v1/challenges/:id
      def show
        if @challenge
          render json: { message: "Challenge found", data: @challenge }
        else
          render json: { message: "Challenge not found", data: @challenge.errors }
        end
      end

      def update
        if @challenge.update(challenges_params)
          render json: { message: "Challenge found", data: @challenge }
        else
          render json: { message: "Challenge not found", data: @challenge.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @challenge.destroy
          render json: { message: "Challenge deleted", data: @challenge }
        else
          render json: { message: "Challenge not found", data: @challenge.errors }, status: :unprocessable_entity
        end
      end

      private

      def authorize_admin
        unless current_user.email == ENV['ADMIN_EMAIL']
          render json: { message: "Forbidden action" }, status: :unauthorized
        end
      end

      def set_challenge
        @challenge = Challenge.find(params[:id])
        render json: { message: "Challenge not found" }, status: :not_found unless @challenge
      end

      def challenges_params
        params.require(:challenge).permit(:title, :description, :start_date, :end_date)
      end
    end
  end
end