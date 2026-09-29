# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JoinGameForm do
  let(:game) { create(:game) }

  it 'adds a new player to an open game' do
    form = JoinGameForm.new(code: game.code.downcase, name: ' Mo ')

    expect(form.save).to be(true)
    expect(form.player).to have_attributes(game:, name: 'Mo')
  end

  it 'rejects names over 16 characters' do
    form = JoinGameForm.new(code: game.code, name: 'a' * 17)

    expect(form.save).to be(false)
    expect(form.errors[:name]).to include('is too long (maximum is 16 characters)')
  end

  it 'asks for confirmation before claiming a taken name' do
    create(:player, game:, name: 'Mo')
    form = JoinGameForm.new(code: game.code, name: 'mo')

    expect(form.save).to be(false)
    expect(form).to be_needs_rejoin_confirmation
  end

  it 'moves a rejoining player to the new phone and off any backup phone' do
    backup = create(:player, game:, backup: true)
    guest = create(:player, game:, name: 'Mo', handler: backup)
    old_token = guest.token

    form = JoinGameForm.new(code: game.code, name: 'Mo', rejoin: true)

    expect(form.save).to be(true)
    expect(guest.reload.token).not_to eq(old_token)
    expect(guest.handler).to be_nil
  end

  it 'lets players rejoin a game that already started' do
    create(:player, game:, name: 'Mo')
    game.in_progress!

    expect(JoinGameForm.new(code: game.code, name: 'Mo', rejoin: true).save).to be(true)
  end

  it 'does not let new players into a started game' do
    game.in_progress!
    form = JoinGameForm.new(code: game.code, name: 'Newbie')

    expect(form.save).to be(false)
    expect(form.errors[:base]).to include('That game already started. Only players already in it can rejoin.')
  end
end
