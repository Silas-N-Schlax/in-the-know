# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'How to play and rules', type: :system do
  it 'opens both pages from the home screen without signing in' do
    visit root_path
    click_on 'How to play'
    expect(page).to have_css('h1', text: 'How to play')

    click_on 'Rules'
    expect(page).to have_css('h1', text: 'Rules')
    expect(page).to have_content('Skip')
  end

  it 'links to both from a phone mid-game' do
    game = create(:game)
    visit root_path
    fill_in 'Game code', with: game.code
    fill_in 'Your name', with: 'Mo'
    click_on 'Join game'

    expect(page).to have_link('How to play')
    expect(page).to have_link('Rules')
  end
end
