# frozen_string_literal: true

module Devices
  # A backup phone adds the people who'll share it.
  class PlayersController < ApplicationController
    include PlayerScoped

    before_action :require_backup_in_lobby

    def new
      @guest = current_game.players.new
    end

    def create
      @guest = current_game.players.new(guest_params.merge(handler: current_player))

      if !current_game.joinable?
        redirect_to play_path, alert: 'The game is full.'
      elsif save_guest
        redirect_to play_path, notice: "#{@guest.name} is in."
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def require_backup_in_lobby
      return if current_player.backup? && current_game.lobby?

      redirect_to play_path, alert: 'Only a backup phone can add players, before the game starts.'
    end

    def guest_params
      params.expect(player: %i[name avatar])
    end

    def save_guest
      @guest.save
    rescue ActiveRecord::RecordNotUnique
      @guest.errors.add(:base, 'That name or animal was just taken. Try again.')
      false
    end
  end
end
