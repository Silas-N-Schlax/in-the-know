# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'join code' do
    it 'gets a 4-letter code with no look-alike characters' do
      game = create(:game)

      expect(game.code).to match(/\A[A-HJ-NP-Z]{4}\z/)
    end

    it 'never repeats a code among games still open' do
      create(:game, code: 'ABCD')
      allow(Game).to receive(:random_code).and_return('ABCD', 'WXYZ')

      new_game = create(:game)

      expect(new_game.code).to eq('WXYZ')
    end
  end

  describe '.max_imposters_for' do
    it 'allows one imposter per three players, rounded down' do
      expect(Game.max_imposters_for(3)).to eq(1)
      expect(Game.max_imposters_for(8)).to eq(2)
      expect(Game.max_imposters_for(9)).to eq(3)
    end

    it 'never goes above six' do
      expect(Game.max_imposters_for(20)).to eq(6)
    end
  end

  describe 'validations' do
    it 'is valid from the default factory' do
      expect(build(:game)).to be_valid
    end

    it 'keeps the player cap between 3 and 20' do
      expect(build(:game, player_cap: 2)).not_to be_valid
      expect(build(:game, player_cap: 21)).not_to be_valid
    end

    it 'keeps rounds between 1 and 15' do
      expect(build(:game, round_count: 0)).not_to be_valid
      expect(build(:game, round_count: 16)).not_to be_valid
    end

    it 'only allows 2, 3, 5 or 7 rotations' do
      expect(build(:game, rotations_per_round: 4)).not_to be_valid
      expect(build(:game, rotations_per_round: 7)).to be_valid
    end

    it 'rejects more imposters than the player cap allows' do
      game = build(:game, player_cap: 8, imposter_min: 1, imposter_max: 3)

      expect(game).not_to be_valid
      expect(game.errors[:imposter_max]).to include('can be at most 2 for 8 players')
    end

    it 'rejects a minimum above the maximum' do
      game = build(:game, player_cap: 12, imposter_min: 3, imposter_max: 2)

      game.validate

      expect(game.errors[:imposter_min]).to include("can't be more than the maximum")
    end

    it 'requires a real category unless the category is random' do
      expect(build(:game, category_mode: :fixed, category: 'Made Up')).not_to be_valid
      expect(build(:game, category_mode: :random, category: nil)).to be_valid
    end

    it 'plays every difficulty by default' do
      expect(Game.new.difficulties).to eq([0, 1, 2])
    end

    it 'needs at least one difficulty and only real ones' do
      expect(build(:game, difficulties: [])).not_to be_valid
      expect(build(:game, difficulties: [3])).not_to be_valid
      expect(build(:game, difficulties: ['', '2', '0'])).to have_attributes(difficulties: [0, 2])
    end

    it 'only allows the offered discussion lengths' do
      expect(build(:game, discussion_seconds: 45)).not_to be_valid
      expect(build(:game, discussion_seconds: 60)).to be_valid
    end
  end

  describe '#joinable?' do
    it 'is joinable in the lobby with room left' do
      game = create(:game, player_cap: 3)
      create_list(:player, 2, game:)

      expect(game).to be_joinable
    end

    it 'is not joinable once full or started' do
      full = create(:game, player_cap: 3)
      create_list(:player, 3, game: full)
      started = create(:game, status: :in_progress)

      expect(full).not_to be_joinable
      expect(started).not_to be_joinable
    end
  end
end
