module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :authenticate_user!

      def index
        @notifications = current_user.notifications.order(created_at: :desc)
        render json: { message: "Notifications retrieved successfully", data: @notifications }
      end

      def mark_as_read
        @notification = Notification.find(params[:id])
        if @notification.update(read: true)
          @notification.destroy
          render json: { message: "Notification marked as read successfully." }, status: :ok
        else
          render json: { message: "Failed to mark notification as read.", data: @notification.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end