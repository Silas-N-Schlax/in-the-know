# frozen_string_literal: true

# Shows one player their word (or hint), privately, then marks it seen.
class RevealsController < ApplicationController
  include PlayerScoped

  before_action :set_seat

  def show
    redirect_to play_path unless @seat.round.revealing?
  end

  def update
    round = @seat.round
    round.with_lock do
      @seat.update!(revealed_at: Time.current) unless @seat.revealed?
      round.start_discussion! if round.revealing? && round.everyone_revealed?
    end
    redirect_to play_path
  end

  private

  def set_seat
    @seat = current_game.current_round&.seats&.find_by(id: params[:seat_id])
    return if @seat && current_player.device_players.include?(@seat.player)

    redirect_to play_path, alert: "That isn't your turn."
  end
end
