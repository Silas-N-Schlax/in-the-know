# frozen_string_literal: true

module Players
  class AvatarsController < ApplicationController
    include PlayerScoped

    before_action :require_lobby

    def edit
      @player = current_player
    end

    def update
      @player = current_player

      if choose_avatar(params.expect(:avatar))
        redirect_to play_path
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def require_lobby
      redirect_to play_path unless current_game.lobby?
    end

    def choose_avatar(avatar)
      @player.update(avatar:)
    rescue ActiveRecord::RecordNotUnique
      @player.avatar = nil
      @player.errors.add(:avatar, 'was just taken. Pick another.')
      false
    end
  end
end
