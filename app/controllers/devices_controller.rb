# frozen_string_literal: true

# The one screen a phone sits on for the whole game. What it shows follows the game's state.
class DevicesController < ApplicationController
  include PlayerScoped

  def show
    return redirect_to(edit_play_avatar_path) if current_player.avatar.nil? && current_game.lobby?

    @screen = PhoneScreenPresenter.new(current_player)
  end
end
