# frozen_string_literal: true

module Host
  class BaseController < ApplicationController
    before_action :authenticate_user!

    private

    def current_game
      @current_game ||= current_user.hosted_games.find(params[:game_id] || params[:id])
    end
  end
end
