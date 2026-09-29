# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Host creates a game', type: :system do
  let(:host) { create(:user) }

  before { sign_in host }

  it 'sets up a game and shows the join code' do
    visit host_games_path
    click_on 'New game'
    find_field('Most players').set(9)
    within(data_test('round_count')) { choose '4' }
    within(data_test('rotations_per_round')) { choose '5' }
    within(data_test('imposter_min')) { choose '1' }
    within(data_test('imposter_max')) { choose '2' }
    select 'Around the House', from: 'Category'
    within(data_test('vote_visibility')) { choose 'Anonymous' }
    within(data_test('pacing')) { choose 'Timed' }
    within(data_test('discussion_seconds')) { choose '1m' }
    click_on 'Create game'

    game = host.hosted_games.last
    expect(page).to have_current_path(host_game_path(game))
    expect(page).to have_content(game.code)
    expect(page).to have_content('Waiting for players')
    expect(game).to have_attributes(player_cap: 9, round_count: 4, rotations_per_round: 5,
                                    imposter_max: 2, category: 'Around the House',
                                    vote_visibility: 'anonymous', discussion_seconds: 60)
  end

  it 'explains settings that do not fit together' do
    visit new_host_game_path
    find_field('Most players').set(5)
    within(data_test('imposter_min')) { choose '1' }
    within(data_test('imposter_max')) { choose '3' }
    click_on 'Create game'

    expect(page).to have_content('can be at most 1 for 5 players')
  end
end
