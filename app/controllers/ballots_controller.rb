# frozen_string_literal: true

# Casts or changes a vote for a player on this phone. Voting closes itself once everyone still in has voted.
class BallotsController < ApplicationController
  include PlayerScoped

  before_action :set_round
  before_action :set_voter

  def create
    ballot = @round.ballots.find_or_initialize_by(rotation: @round.current_rotation, voter_seat: @voter)
    ballot.target_seat = params[:target_seat_id].presence && @round.seats.find_by(id: params[:target_seat_id])

    if save_ballot(ballot)
      VoteTally.new(@round).close! if @round.everyone_voted?
      redirect_to play_path
    else
      redirect_to play_path, alert: ballot.errors.full_messages.to_sentence
    end
  end

  def destroy
    @round.ballots.where(rotation: @round.current_rotation, voter_seat: @voter).destroy_all
    redirect_to play_path
  end

  private

  def set_round
    @round = current_game.current_round
    redirect_to play_path, alert: 'Voting is closed.' unless @round&.voting?
  end

  def set_voter
    @voter = @round.seats.find_by(id: params[:voter_seat_id] || params[:id])
    return if @voter && current_player.device_players.include?(@voter.player)

    redirect_to play_path, alert: "That isn't your vote."
  end

  def save_ballot(ballot)
    ballot.save
  rescue ActiveRecord::RecordNotUnique
    ballot.errors.add(:base, 'That vote was already counted.')
    false
  end
end
