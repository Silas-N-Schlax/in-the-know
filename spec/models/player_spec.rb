# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:game) { create(:game) }

  describe 'names' do
    it 'squishes extra spaces' do
      player = create(:player, game:, name: '  Big   Mo  ')

      expect(player.name).to eq('Big Mo')
    end

    it 'must be unique in a game, ignoring case and spaces' do
      create(:player, game:, name: 'Big Mo')
      duplicate = build(:player, game:, name: ' big  mo ')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('is already in this game')
    end

    it 'can repeat across games' do
      create(:player, game:, name: 'Big Mo')

      expect(build(:player, game: create(:game), name: 'Big Mo')).to be_valid
    end

    it 'allows at most 16 characters' do
      expect(build(:player, game:, name: 'a' * 16)).to be_valid
      expect(build(:player, game:, name: 'a' * 17)).not_to be_valid
    end
  end

  describe 'avatars' do
    it 'must be one of the animals' do
      expect(build(:player, game:, avatar: 'dragon')).not_to be_valid
      expect(build(:player, game:, avatar: 'raccoon')).not_to be_valid
    end

    it 'can only be used once per game' do
      create(:player, game:, avatar: 'otter')

      duplicate = build(:player, game:, avatar: 'otter')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:avatar]).to include('was just taken. Pick another.')
    end
  end

  describe '.available_avatars' do
    it 'lists the animals nobody in the game has picked' do
      create(:player, game:, avatar: 'otter')
      create(:player, game:, avatar: 'fox')

      expect(game.players.available_avatars).not_to include('otter', 'fox')
      expect(game.players.available_avatars.size).to eq(18)
    end
  end

  describe '#device_players' do
    it 'is just the player on a regular phone' do
      player = create(:player, game:)

      expect(player.device_players).to eq([player])
    end

    it 'includes the players a backup phone looks after' do
      backup = create(:player, game:, backup: true)
      guest = create(:player, game:, handler: backup)

      expect(backup.device_players).to eq([backup, guest])
    end
  end
end
