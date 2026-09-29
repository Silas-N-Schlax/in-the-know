# frozen_string_literal: true

# For the phone screens: everything acts on the player this phone's cookie remembers.
module PlayerScoped
  extend ActiveSupport::Concern

  included do
    before_action :require_player
  end

  private

  def require_player
    return if current_player

    forget_player
    redirect_to root_path, alert: 'This phone is not in a game. Join with the code on the host screen.'
  end

  def current_game
    current_player.game
  end

  # A player this phone may act for: itself, or one of the players a backup phone looks after.
  def device_player(id)
    current_player.device_players.find { |player| player.id == id.to_i } || raise(ActiveRecord::RecordNotFound)
  end
end
