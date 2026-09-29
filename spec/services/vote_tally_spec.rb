# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoteTally do
  let(:round) { create(:round, status: :voting, current_rotation: 1) }
  let!(:ann) { create(:seat, round:) }
  let!(:ben) { create(:seat, round:) }
  let!(:cat) { create(:seat, round:) }
  let!(:dee) { create(:seat, :imposter, round:) }

  def vote(voter, target)
    round.ballots.create!(rotation: 1, voter_seat: voter, target_seat: target)
  end

  it 'puts out a player with the most votes' do
    vote(ann, dee)
    vote(ben, dee)
    vote(cat, dee)
    vote(dee, ann)

    result = VoteTally.new(round).count

    expect(result.outcome).to eq(:voted_out)
    expect(result.seat).to eq(dee)
  end

  it 'puts nobody out on a tie' do
    vote(ann, dee)
    vote(ben, dee)
    vote(cat, ann)
    vote(dee, ann)

    expect(VoteTally.new(round).count.outcome).to eq(:tied)
  end

  it 'puts nobody out when Skip gets the most votes' do
    vote(ann, nil)
    vote(ben, nil)
    vote(cat, dee)

    expect(VoteTally.new(round).count.outcome).to eq(:skipped)
  end

  it 'counts anyone who did not vote as Skip' do
    vote(ann, dee)

    result = VoteTally.new(round).count

    expect(result.outcome).to eq(:skipped)
    expect(result.counts[nil]).to eq(3)
  end

  it 'only counts ballots from this trip around the table' do
    round.ballots.create!(rotation: 2, voter_seat: ann, target_seat: dee)

    expect(VoteTally.new(round).count.counts[dee]).to be_nil
  end
end
