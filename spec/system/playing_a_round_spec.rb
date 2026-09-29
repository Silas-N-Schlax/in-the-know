# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Playing a round', type: :system do
  let(:host) { create(:user) }
  let!(:game) { create(:game, host:, round_count: 1, rotations_per_round: 2, pacing: :manual, category: 'Around the House') }

  def join_as(name, avatar)
    using_session(name) do
      visit root_path
      fill_in 'Game code', with: game.code
      fill_in 'Your name', with: name
      click_on 'Join game'
      click_on avatar
    end
  end

  def on_phone(name, &)
    using_session(name) do
      visit play_path
      yield
    end
  end

  def on_host(&)
    using_session('host') do
      sign_in host
      visit host_game_path(game)
      yield
    end
  end

  def seat_for(name)
    game.current_round.seats.joins(:player).find_by(players: { name: })
  end

  def reveal(name)
    on_phone(name) do
      click_on 'Show my word'
      yield if block_given?
      click_on 'Got it'
    end
  end

  def vote(name, for_name)
    on_phone(name) { click_on(for_name || 'Skip') }
  end

  before do
    join_as('Ann', 'Otter')
    join_as('Ben', 'Fox')
    join_as('Cat', 'Owl')
    join_as('Dee', 'Frog')
  end

  it 'reveals words privately, votes, and scores the round' do
    on_host { click_on 'Start game' }
    round = game.reload.current_round
    imposter = round.seats.imposter.first.player.name
    insiders = %w[Ann Ben Cat Dee] - [imposter]

    reveal(insiders.first) { expect(page).to have_content(round.word) }
    reveal(imposter) do
      expect(page).to have_content("You're the imposter")
      expect(page).to have_content(round.imposter_hint)
      expect(page).to have_no_content(round.word)
    end
    insiders.drop(1).each { |name| reveal(name) }

    on_host do
      expect(page).to have_content('Trip 1 of 2')
      click_on 'Start vote'
    end

    insiders.each { |name| vote(name, imposter) }
    vote(imposter, insiders.first)

    on_host do
      expect(page).to have_content('Insiders win')
      expect(page).to have_content(round.word)
      expect(page).to have_content('Final scores')
    end
    on_phone(insiders.first) { expect(page).to have_content('Insiders win') }
    expect(game.reload).to be_finished
    expect(game.players.find_by(name: insiders.first).points).to eq(1)
  end

  it 'shows who is out, keeps them from voting, and moves to the next trip' do
    on_host { click_on 'Start game' }
    round = game.reload.current_round
    imposter = round.seats.imposter.first.player.name
    insiders = %w[Ann Ben Cat Dee] - [imposter]
    %w[Ann Ben Cat Dee].each { |name| reveal(name) }
    on_host { click_on 'Start vote' }

    insiders.first(2).each { |name| vote(name, insiders.last) }
    vote(insiders.last, insiders.first)
    vote(imposter, insiders.last)

    on_host do
      expect(page).to have_content("#{insiders.last} is out")
      expect(page).to have_content('was an Insider')
      click_on 'Next trip'
      expect(page).to have_content('Trip 2 of 2')
    end
    on_phone(insiders.last) { expect(page).to have_content("You're out") }
  end

  it 'lets the host end a vote early, counting missing votes as Skip' do
    on_host { click_on 'Start game' }
    %w[Ann Ben Cat Dee].each { |name| reveal(name) }
    on_host { click_on 'Start vote' }

    vote('Ann', 'Ben')

    on_host do
      click_on 'End vote'
      expect(page).to have_content('Nobody is out')
    end
  end

  it 'lets players change their vote until voting closes' do
    on_host { click_on 'Start game' }
    %w[Ann Ben Cat Dee].each { |name| reveal(name) }
    on_host { click_on 'Start vote' }

    vote('Ann', 'Ben')
    on_phone('Ann') { click_on 'Change vote' }
    vote('Ann', 'Cat')

    expect(game.current_round.ballots.sole.target_seat).to eq(seat_for('Cat'))
  end
end
