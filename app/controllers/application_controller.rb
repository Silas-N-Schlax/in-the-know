# frozen_string_literal: true

class ApplicationController < ActionController::Base
  PLAYER_COOKIE = :player_token

  helper_method :current_player

  private

  # The player this phone belongs to. Phones are remembered by a signed, permanent cookie.
  def current_player
    return @current_player if defined?(@current_player)

    token = cookies.signed[PLAYER_COOKIE]
    @current_player = token && Player.find_by(token:)
  end

  def remember_player(player)
    cookies.signed.permanent[PLAYER_COOKIE] = { value: player.token, httponly: true, same_site: :lax }
  end

  def forget_player
    cookies.delete(PLAYER_COOKIE)
  end

  def after_sign_in_path_for(_user)
    host_games_path
  end

  def after_sign_out_path_for(_user)
    root_path
  end
end
