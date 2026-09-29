# frozen_string_literal: true

# Standings with shared ranks for ties, plus who scored in the latest round.
class LeaderboardPresenter
  Row = Data.define(:rank, :player, :points, :scored_last_round)

  def initialize(game)
    @game = game
  end

  def rows
    @rows ||= begin
      scorers = last_round_scorer_ids
      players = @game.players.active.or(@game.players.where(points: 1..)).order(points: :desc, name: :asc).to_a
      players.map do |player|
        rank = players.index { |other| other.points == player.points } + 1
        Row.new(rank:, player:, points: player.points, scored_last_round: scorers.include?(player.id))
      end
    end
  end

  def leaders
    rows.select { |row| row.rank == 1 && row.points.positive? }
  end

  private

  def last_round_scorer_ids
    round = @game.current_round
    return Set.new unless round&.finished?

    round.seats.where(points_earned: 1..).pluck(:player_id).to_set
  end
end
