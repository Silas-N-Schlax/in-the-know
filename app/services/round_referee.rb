# frozen_string_literal: true

# Decides whether a round is over and hands out points.
#
# - Insiders win the moment every imposter is out.
# - Imposters win the moment it's down to one imposter and one Insider, or only imposters are left.
# - Otherwise imposters win if any are still in after the last trip's vote.
class RoundReferee
  def initialize(round)
    @round = round
  end

  def winner(after_vote: true)
    playing = @round.seats.playing
    imposters = playing.imposter.count
    insiders = playing.insider.count

    return :insiders if imposters.zero?
    return :imposters if insiders.zero? || (imposters == 1 && insiders == 1)
    return :imposters if after_vote && @round.last_rotation?

    nil
  end

  # After a vote the round either ends or moves on to showing the result.
  # After a removal the round only ends if the removal decided it.
  def settle!(after_vote: true)
    result = winner(after_vote:)

    if result
      finish!(result)
    elsif after_vote
      @round.update!(status: :reviewing)
    end
  end

  private

  def finish!(result)
    Round.transaction do
      @round.update!(status: :finished, winner: result)
      award_points(result == :insiders ? :insider : :imposter)
      @round.game.finished! if @round.game.last_round?
    end
  end

  # Every winner scores, including those voted out. Players removed from the round don't.
  def award_points(role)
    @round.seats.where(role:).where.not(status: :removed).includes(:player).find_each do |seat|
      seat.update!(points_earned: 1)
      seat.player.increment!(:points) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
