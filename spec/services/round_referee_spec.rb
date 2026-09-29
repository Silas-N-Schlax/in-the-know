# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoundReferee do
  let(:game) { create(:game, :in_progress, rotations_per_round: 3, round_count: 3) }
  let(:round) { create(:round, game:, status: :voting, current_rotation: 1) }

  def seat(role = :insider, status: :playing)
    create(:seat, round:, role:, status:)
  end

  describe '#winner' do
    it 'is the Insiders once every imposter is out' do
      seat
      seat
      seat(:imposter, status: :voted_out)

      expect(RoundReferee.new(round).winner).to eq(:insiders)
    end

    it 'is the imposters when it is down to one imposter and one Insider' do
      seat
      seat(status: :voted_out)
      seat(:imposter)

      expect(RoundReferee.new(round).winner).to eq(:imposters)
    end

    it 'is the imposters when only imposters are left' do
      seat(status: :voted_out)
      seat(:imposter)
      seat(:imposter)

      expect(RoundReferee.new(round).winner).to eq(:imposters)
    end

    it 'is nobody yet while the round can still go either way' do
      seat
      seat
      seat(:imposter)
      seat(:imposter)

      expect(RoundReferee.new(round).winner).to be_nil
    end

    it 'is the imposters once the last trip is done and one survived' do
      round.update!(current_rotation: 3)
      seat
      seat
      seat
      seat(:imposter)

      expect(RoundReferee.new(round).winner).to eq(:imposters)
    end
  end

  describe '#settle!' do
    it 'moves on to reviewing the vote while nobody has won' do
      4.times { seat }
      seat(:imposter)

      RoundReferee.new(round).settle!

      expect(round.reload).to be_reviewing
    end

    it 'finishes the round and gives every Insider a point, even ones voted out' do
      winner = seat
      out_insider = seat(status: :voted_out)
      imposter = seat(:imposter, status: :voted_out)

      RoundReferee.new(round).settle!

      expect(round.reload).to have_attributes(status: 'finished', winner: 'insiders')
      expect(winner.player.reload.points).to eq(1)
      expect(out_insider.player.reload.points).to eq(1)
      expect(imposter.player.reload.points).to eq(0)
    end

    it 'gives every imposter a point when they win, including ones voted out' do
      seat
      seat(status: :voted_out)
      survivor = seat(:imposter)
      caught = seat(:imposter, status: :voted_out)

      RoundReferee.new(round).settle!

      expect(survivor.player.reload.points).to eq(1)
      expect(caught.player.reload.points).to eq(1)
    end

    it 'gives nobody removed from the round a point' do
      seat
      seat
      removed = seat(status: :removed)
      seat(:imposter, status: :voted_out)

      RoundReferee.new(round).settle!

      expect(removed.player.reload.points).to eq(0)
    end

    it 'finishes the game after the last round' do
      round.update!(number: 3)
      seat
      seat
      seat(:imposter, status: :voted_out)

      RoundReferee.new(round).settle!

      expect(game.reload).to be_finished
    end
  end
end
