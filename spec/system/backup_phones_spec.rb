# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backup phones', type: :system do
  let(:host) { create(:user) }
  let!(:game) { create(:game, host:, player_cap: 6, round_count: 1, pacing: :manual) }

  def join_as(name, avatar)
    using_session(name) do
      visit root_path
      fill_in 'Game code', with: game.code
      fill_in 'Your name', with: name
      click_on 'Join game'
      click_on avatar
    end
  end

  before do
    join_as('Ann', 'Otter')
    join_as('Ben', 'Fox')
  end

  it 'lets the host make a backup phone that adds players and passes itself around' do
    using_session('host') do
      sign_in host
      visit host_game_path(game)
      within(data_test(game.players.find_by(name: 'Ann'))) { click_on 'Make backup' }
      expect(page).to have_content('Backup phone')
    end

    using_session('Ann') do
      visit play_path
      click_on 'Add player'
      fill_in 'Name', with: 'Gran'
      click_on 'Koala'
      expect(page).to have_content('Gran')

      click_on 'Add player'
      fill_in 'Name', with: 'ben'
      click_on 'Sloth'
      expect(page).to have_content('is already in this game')
    end

    using_session('host') do
      visit host_game_path(game)
      click_on 'Start game'
    end

    using_session('Ann') do
      visit play_path
      expect(page).to have_content('Pass the phone to')
      first_up = find('.handoff__name').text
      click_on 'Show my word'
      click_on 'Got it'

      expect(page).to have_content('Pass the phone to')
      expect(find('.handoff__name').text).not_to eq(first_up)
      click_on 'Show my word'
      click_on 'Got it'
    end
  end

  it 'will not undo a backup that is still looking after players' do
    ann = game.players.find_by(name: 'Ann')
    ann.update!(backup: true)
    create(:player, game:, name: 'Gran', avatar: 'koala', handler: ann)

    using_session('host') do
      sign_in host
      visit host_game_path(game)
      within(data_test(ann)) { click_on 'Undo backup' }

      expect(page).to have_content("Ann's phone is still looking after Gran")
      expect(ann.reload).to be_backup
    end
  end
end
