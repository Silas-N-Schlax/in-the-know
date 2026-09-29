# frozen_string_literal: true

module AvatarsHelper
  # Classes that tint a page or element in the player's animal color (see components/player-theme.css).
  def player_theme(player)
    return unless player&.avatar

    "player-theme player-theme--#{player.avatar.dasherize}"
  end

  # Avatar art lives in app/assets/images/avatars. Until a PNG exists, fall back to a plain path
  # so the page still renders (with a broken image) instead of raising.
  def avatar_src(avatar)
    asset_path("avatars/#{avatar}.png")
  rescue Propshaft::MissingAssetError
    "/avatars/#{avatar}.png"
  end
end
