# frozen_string_literal: true

module AvatarsHelper
  # Avatar art lives in app/assets/images/avatars. Until a PNG exists, fall back to a plain path
  # so the page still renders (with a broken image) instead of raising.
  def avatar_src(avatar)
    asset_path("avatars/#{avatar}.png")
  rescue Propshaft::MissingAssetError
    "/avatars/#{avatar}.png"
  end
end
