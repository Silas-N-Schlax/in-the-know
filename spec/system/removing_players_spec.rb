# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Removing players', type: :system do
  let(:host) { create(:user) }
  let(:game) { create(:game, :in_progress, host:, round_count: 3, rotations_per_round: 3) }
  let(:round) { create(:round, game:, number: 1, status: :discussing) }
  let!(:ann) { create(:seat, round:, player: create(:player, game:, name: 'Ann', avatar: 'otter')) }
  let!(:ben) { create(:seat, round:, player: create(:player, game:, name: 'Ben', avatar: 'fox')) }
  let!(:cat) { create(:seat, round:, player: create(:player, game:, name: 'Cat', avatar: 'owl')) }
  let!(:dee) { create(:seat, :imposter, round:, player: create(:player, game:, name: 'Dee', avatar: 'frog')) }

  before { sign_in host }

  it 'removes a player for just this round' do
    visit host_game_path(game)
    within(data_test(ann)) { click_on 'Remove Ann' }
    choose 'Just this round'
    click_on 'Remove'

    expect(ann.reload).to be_removed
    expect(ann.player.reload).to be_active
  end

  it 'removes a player for the rest of the game' do
    visit host_game_path(game)
    within(data_test(ann)) { click_on 'Remove Ann' }
    choose 'Rest of the game'
    click_on 'Remove'

    expect(ann.reload).to be_removed
    expect(ann.player.reload).to be_removed
  end

  it 'ends the round when the last imposter is removed' do
    visit host_game_path(game)
    within(data_test(dee)) { click_on 'Remove Dee' }
    choose 'Just this round'
    click_on 'Remove'

    expect(page).to have_content('Insiders win')
    expect(round.reload).to be_won_by_insiders
  end

  it 'removes a player outright while the game is still in the lobby' do
    lobby = create(:game, host:)
    player = create(:player, game: lobby, name: 'Zed')

    visit host_game_path(lobby)
    within(data_test(player)) { click_on 'Remove' }
    click_on 'Remove'

    expect(page).to have_content('Zed was removed')
    expect(lobby.players).to be_empty
  end
end
