# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Revealing your note', :js, type: :system do
  let!(:game) { create(:game) }

  it 'opens the envelope to show the card, then tucks it away and moves on' do
    visit root_path
    fill_in 'Game code', with: game.code
    fill_in 'Your name', with: 'Ann'
    click_on 'Join game'
    click_on 'Otter'
    expect(page).to have_content("You're in, Ann")

    player = game.players.find_by!(name: 'Ann')
    game.in_progress!
    round = create(:round, game:, status: :revealing, word: 'Pancake')
    seat = create(:seat, round:, player:)
    create(:seat, round:)

    visit play_reveal_path(seat)
    expect(page).to have_css('.reveal[data-envelope-state="closed"]')
    expect(page).to have_no_button('Got it')

    click_on "Open Ann's note"

    expect(page).to have_css('.reveal[data-envelope-state="card-front"]')
    expect(page).to have_content('Pancake')
    click_on 'Got it'

    expect(page).to have_current_path(play_path)
    expect(seat.reload).to be_revealed
  end
end
