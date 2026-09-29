# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoundDealer do
  def game_with_players(count, **settings)
    game = create(:game, player_cap: 20, **settings)
    Player::AVATARS.first(count).each_with_index { |avatar, i| create(:player, game:, name: "P#{i}", avatar:) }
    game.in_progress!
    game
  end

  it 'deals a seat to every active player with one role each' do
    game = game_with_players(6)

    round = RoundDealer.new(game).deal!

    expect(round.seats.count).to eq(6)
    expect(round.seats.imposter.count).to eq(1)
    expect(round).to have_attributes(number: 1, status: 'revealing', current_rotation: 1)
  end

  it 'picks an imposter count within the range' do
    game = game_with_players(12, imposter_min: 2, imposter_max: 4)

    counts = Array.new(15) { RoundDealer.new(game).deal!.seats.imposter.count }

    expect(counts).to all(be_between(2, 4))
  end

  it 'lowers the range when fewer players joined than the settings expected' do
    game = game_with_players(6, imposter_min: 3, imposter_max: 4)

    round = RoundDealer.new(game).deal!

    expect(round.seats.imposter.count).to eq(2)
  end

  it "uses the game's category and never repeats a word" do
    game = game_with_players(3, category: 'Everyday')

    words = Array.new(10) { RoundDealer.new(game).deal! }.map(&:word)

    expect(words.uniq.size).to eq(10)
    expect(game.rounds.pluck(:category).uniq).to eq(['Everyday'])
  end

  it 'only deals words at the chosen difficulties' do
    game = game_with_players(3, difficulties: [0])

    rounds = Array.new(8) { RoundDealer.new(game).deal! }

    difficulties = rounds.map { |round| WordBank.entries.find { |entry| entry.word == round.word }.difficulty }
    expect(difficulties.uniq).to eq([0])
  end

  it 'draws from any category when the game is random' do
    game = game_with_players(3, category_choice: Game::RANDOM_CATEGORY)

    round = RoundDealer.new(game).deal!

    expect(WordBank.categories).to include(round.category)
  end

  it 'leaves out players removed for the rest of the game' do
    game = game_with_players(4)
    game.players.last.removed!

    round = RoundDealer.new(game).deal!

    expect(round.seats.count).to eq(3)
  end
end
