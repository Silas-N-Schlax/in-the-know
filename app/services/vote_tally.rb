# frozen_string_literal: true

# Counts the current trip's vote. Anyone still in who didn't vote counts as Skip.
# The most-voted player goes out; a tie or Skip on top means nobody does.
class VoteTally
  Result = Data.define(:outcome, :seat, :counts) do
    def total_for(seat) = counts.fetch(seat, 0)
  end

  def initialize(round)
    @round = round
  end

  def count
    counts = tally
    leaders = leaders_of(counts)

    outcome = if leaders.size != 1 then :tied
              elsif leaders.first.nil? then :skipped
              else :voted_out
              end
    outcome = :skipped if counts.empty?

    Result.new(outcome:, seat: (leaders.first if outcome == :voted_out), counts:)
  end

  # Closes voting once, even if the last voter and the host's "End vote" arrive together.
  def close!
    @round.with_lock do
      next unless @round.voting?

      result = count
      result.seat&.update!(status: :voted_out, out_in_rotation: @round.current_rotation)
      @round.update!(last_vote_outcome: result.outcome, last_voted_out_seat: result.seat)
      RoundReferee.new(@round).settle!
      result
    end
  end

  def ballots
    @round.ballots.for_rotation(@round.current_rotation).includes(voter_seat: :player, target_seat: :player)
  end

  private

  def tally
    voters = @round.voters.to_a
    cast = ballots.select { |ballot| voters.include?(ballot.voter_seat) }

    counts = {}
    cast.each { |ballot| counts[ballot.target_seat] = counts.fetch(ballot.target_seat, 0) + 1 }
    missing = voters.size - cast.size
    counts[nil] = counts.fetch(nil, 0) + missing if missing.positive?
    counts
  end

  def leaders_of(counts)
    top = counts.values.max
    counts.select { |_seat, votes| votes == top }.keys
  end
end
