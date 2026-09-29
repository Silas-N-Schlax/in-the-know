# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_super_admin

    private

    def require_super_admin
      return if current_user.super_admin?

      redirect_to host_games_path, alert: 'Only super admins can do that.'
    end
  end
end
