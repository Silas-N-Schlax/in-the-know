# frozen_string_literal: true

# Takes a player out mid-game. It counts like being voted out, so it can end the round,
# e.g. removing the last imposter hands the Insiders the win.
class PlayerRemoval
  def initialize(player, rest_of_game:)
    @player = player
    @rest_of_game = rest_of_game
  end

  def remove!
    round = @player.game.current_round

    Round.transaction do
      @player.removed! if @rest_of_game
      settle(round) if round && !round.finished?
    end
  end

  private

  def settle(round)
    round.with_lock do
      seat = round.seats.find_by(player: @player)
      next unless seat&.playing?

      seat.update!(status: :removed, out_in_rotation: round.current_rotation)
      round.ballots.for_rotation(round.current_rotation).where(voter_seat: seat).destroy_all
      referee_or_close_vote(round)
    end
  end

  # If they were the last one yet to vote, removing them finishes the vote; otherwise just check for a win.
  def referee_or_close_vote(round)
    if round.voting? && round.everyone_voted?
      VoteTally.new(round).close!
    else
      RoundReferee.new(round).settle!(after_vote: false)
    end
  end
end
