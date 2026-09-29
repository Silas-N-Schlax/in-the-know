# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Player colors', type: :system do
  let!(:game) { create(:game) }

  def join_as(name, animal)
    visit root_path
    fill_in 'Game code', with: game.code
    fill_in 'Your name', with: name
    click_on 'Join game'
    click_on animal
  end

  it "themes a player's phone in their animal's color" do
    join_as('Ann', 'Red Panda')

    expect(page).to have_css('body.player-theme.player-theme--red-panda')
  end

  it 'themes a backup phone for whoever is holding it' do
    join_as('Ann', 'Otter')
    ann = game.players.find_by!(name: 'Ann')
    ann.update!(backup: true)
    gran = create(:player, game:, name: 'Gran', avatar: 'koala', handler: ann)
    game.in_progress!
    round = create(:round, game:, status: :revealing)
    create(:seat, round:, player: ann, revealed_at: Time.current)
    create(:seat, round:, player: gran)

    visit play_path

    expect(page).to have_content('Pass the phone to Gran')
    expect(page).to have_css('body.player-theme--koala')
  end

  it "writes each player's name in their color on the host screen" do
    host = game.host
    player = create(:player, game:, name: 'Mo', avatar: 'fox')
    sign_in host

    visit host_game_path(game)

    expect(page).to have_css("#{data_test(player)}.player-theme--fox", text: 'Mo')
  end
end
