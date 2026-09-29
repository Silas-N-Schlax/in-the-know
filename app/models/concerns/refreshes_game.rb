# frozen_string_literal: true

# Any change to game state tells every screen in the game to re-fetch its own page.
# The broadcast carries no data, so secret words never go to the wrong phone.
module RefreshesGame
  extend ActiveSupport::Concern

  included do
    after_commit :refresh_game_screens
  end

  private

  def refresh_game_screens
    target = is_a?(Game) ? self : game
    target.broadcast_refresh if target && !target.destroyed?
  end
end
