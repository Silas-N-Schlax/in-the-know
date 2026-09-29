# frozen_string_literal: true

module Host
  class BaseController < ApplicationController
    before_action :authenticate_user!

    rescue_from ActiveRecord::RecordNotFound do
      redirect_to host_games_path, alert: "That game doesn't exist or isn't yours."
    end

    private

    def current_game
      @current_game ||= current_user.hosted_games.find(params[:game_id] || params[:id])
    end
  end
end
