# frozen_string_literal: true

# Permanently deletes a game and everything played in it. Rows are removed in foreign-key order
# (votes, seats, rounds, players, game) so a half-played game can't trip over its own references.
# Any phone still in the game refreshes and lands back on the join screen.
class GameDeletion
  def initialize(game)
    @game = game
  end

  def delete!
    Game.transaction do
      round_ids = @game.rounds.ids
      Ballot.where(round_id: round_ids).delete_all
      Round.where(id: round_ids).update_all(last_voted_out_seat_id: nil) # rubocop:disable Rails/SkipsModelValidations
      Seat.where(round_id: round_ids).delete_all
      Round.where(id: round_ids).delete_all
      @game.players.update_all(handler_id: nil) # rubocop:disable Rails/SkipsModelValidations
      @game.players.delete_all
      @game.delete
    end

    @game.broadcast_refresh
  end
end
