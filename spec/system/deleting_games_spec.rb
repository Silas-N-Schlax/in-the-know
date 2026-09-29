# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deleting games', type: :system do
  let(:host) { create(:user) }

  before { sign_in host }

  def open_delete_for(game, tab: nil)
    visit host_games_path(tab:)
    within(data_test(game)) { click_on 'Delete' }
  end

  it 'deletes a finished game once its code is typed' do
    game = create(:game, host:, code: 'WXYZ', status: :finished, finished_at: 1.hour.ago)

    open_delete_for(game, tab: 'finished')
    fill_in 'Type the game code', with: 'wxyz'
    click_on 'Delete game'

    expect(page).to have_content('Game WXYZ was deleted.')
    expect(Game.exists?(game.id)).to be(false)
  end

  it 'refuses a wrong code' do
    game = create(:game, host:, code: 'WXYZ')

    open_delete_for(game)
    fill_in 'Type the game code', with: 'ABCD'
    click_on 'Delete game'

    expect(page).to have_content("That code doesn't match this game")
    expect(Game.exists?(game.id)).to be(true)
  end

  it "does not let a host delete someone else's game" do
    other = create(:game, code: 'NOPE')

    visit new_host_game_deletion_path(other)

    expect(page).to have_no_content('Delete game')
    expect(Game.exists?(other.id)).to be(true)
  end

  it 'works from the modal in a real browser, keeping the modal open on a mistake', :js do
    game = create(:game, host:, code: 'WXYZ', status: :in_progress)

    open_delete_for(game)
    within(data_test('modal-content')) do
      fill_in 'Type the game code', with: 'NOPE'
        click_on 'Delete game'
      expect(page).to have_content("That code doesn't match this game")

      fill_in 'Type the game code', with: 'WXYZ'
        click_on 'Delete game'
    end

    expect(page).to have_content('Game WXYZ was deleted.')
    expect(page).to have_no_css(data_test(game))
  end
end
