# frozen_string_literal: true

module Admin
  module Users
    class SetupLinksController < BaseController
      def create
        user = User.find(params[:user_id])

        if user.awaiting_setup?
          user.invite!(current_user) { |invitee| invitee.skip_invitation = true }
          redirect_to admin_user_path(user), flash: { setup_token: user.raw_invitation_token }
        else
          redirect_to admin_user_path(user), alert: "#{user.display_name} has already finished setup."
        end
      end
    end
  end
end
