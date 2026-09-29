# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Joining a game', type: :system do
  let!(:game) { create(:game, player_cap: 4) }

  def join(code: game.code, name: 'Mo')
    visit root_path
    fill_in 'Game code', with: code
    fill_in 'Your name', with: name
    click_on 'Join game'
  end

  it 'joins with the code and a name, then picks an animal' do
    join(code: game.code.downcase, name: '  Big  Mo ')

    expect(page).to have_content('Pick your animal')
    click_on 'Otter'

    expect(page).to have_content("You're in, Big Mo")
    expect(game.players.last).to have_attributes(name: 'Big Mo', avatar: 'otter')
  end

  it 'explains an unknown code' do
    join(code: 'ZZZZ')

    expect(page).to have_content('No open game has that code')
  end

  it 'explains a blank name and stops typing at 16 characters' do
    join(name: '')
    expect(page).to have_content("can't be blank")

    expect(find_field('Your name')[:maxlength]).to eq('16')
  end

  it 'explains a full game' do
    create_list(:player, 4, game:)

    join

    expect(page).to have_content('That game is full')
  end

  it 'explains a game that already started' do
    game.in_progress!

    join

    expect(page).to have_content('That game already started')
  end

  it 'hides animals other players already picked' do
    create(:player, game:, avatar: 'fox')

    join

    expect(page).to have_button('Otter')
    expect(page).to have_button('Fox', disabled: true)
  end

  it 'explains when someone just grabbed the same animal' do
    join
    create(:player, game:, avatar: 'otter')

    click_on 'Otter'

    expect(page).to have_content('Otter was just taken. Pick another.')
    expect(page).to have_button('Otter', disabled: true)
  end

  it 'offers to rejoin with a taken name and moves the player to the new phone' do
    player = create(:player, game:, name: 'Mo', avatar: 'owl')
    old_token = player.token
    game.in_progress!
    create(:seat, round: create(:round, game:, status: :revealing), player:)

    join(name: 'mo')
    expect(page).to have_content('Mo is already in this game')
    click_on "I'm Mo, rejoin"

    expect(player.reload.token).not_to eq(old_token)
    expect(page).to have_current_path(play_path)
  end

  it 'lets the player pick a different name instead of rejoining' do
    create(:player, game:, name: 'Mo', avatar: 'owl')

    join(name: 'Mo')
    click_on 'Pick a different name'

    expect(find_field('Your name').value).to be_blank
    expect(page).to have_field('Game code', with: game.code)
  end

  it 'greys out an animal on other phones the moment it is picked', :js do
    join(name: 'First')
    expect(page).to have_content('Pick your animal')
    wait_for_stream_connection

    create(:player, game:, name: 'Second').update!(avatar: 'otter')

    expect(page).to have_button('Otter', disabled: true)
  end
end
