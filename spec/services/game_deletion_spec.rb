# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameDeletion do
  it 'removes a game that was played, with its players, rounds, seats and votes' do
    game = create(:game, :in_progress)
    backup = create(:player, game:, backup: true)
    create(:player, game:, handler: backup)
    round = create(:round, game:, status: :reviewing)
    voter = create(:seat, round:, player: backup)
    target = create(:seat, round:)
    round.ballots.create!(rotation: 1, voter_seat: voter, target_seat: target)
    target.update!(status: :voted_out)
    round.update!(last_vote_outcome: :voted_out, last_voted_out_seat: target)

    GameDeletion.new(game).delete!

    expect(Game.exists?(game.id)).to be(false)
    expect([Player, Round, Seat, Ballot].map { |model| model.count }).to all(eq(0))
  end
end
