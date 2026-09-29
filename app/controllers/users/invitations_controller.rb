# frozen_string_literal: true

# First sign in: the new user opens their one-time setup link and picks a name and password.
module Users
  class InvitationsController < Devise::InvitationsController
    before_action :configure_accept_invitation_params, only: :update

    # Accounts are created by super admins in Admin::UsersController, never here.
    def new = redirect_to(root_path)
    def create = redirect_to(root_path)

    private

    def configure_accept_invitation_params
      devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name password password_confirmation])
    end

    def resource_from_invitation_token
      token = params[:invitation_token] || params.dig(:user, :invitation_token)
      self.resource = token && resource_class.find_by_invitation_token(token, true)
      return if resource&.awaiting_setup?

      redirect_to root_path, alert: 'That setup link is invalid or has already been used.'
    end

    def after_accept_path_for(_user)
      host_games_path
    end
  end
end
