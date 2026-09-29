# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account setup', type: :system do
  let(:user) { User.invite!(email: 'fresh@example.com') { |u| u.skip_invitation = true } }
  let(:setup_path) { accept_user_invitation_path(invitation_token: user.raw_invitation_token) }

  it 'lets a new user set their name and password and signs them in' do
    visit setup_path
    fill_in 'Your name', with: 'Fresh Face'
    fill_in 'New password', with: 'hunter222'
    fill_in 'Password again', with: 'hunter222'
    click_on 'Finish setup'

    expect(page).to have_current_path(host_games_path)
    expect(user.reload.name).to eq('Fresh Face')
    expect(user).not_to be_awaiting_setup
  end

  it 'shows an error when the passwords do not match' do
    visit setup_path
    fill_in 'Your name', with: 'Fresh Face'
    fill_in 'New password', with: 'hunter222'
    fill_in 'Password again', with: 'hunter333'
    click_on 'Finish setup'

    expect(page).to have_content("Password again doesn't match")
  end

  it 'does not work a second time' do
    path = setup_path
    user.assign_attributes(name: 'Already Here', password: 'hunter222', password_confirmation: 'hunter222')
    user.accept_invitation!

    visit path

    expect(page).to have_content('That setup link is invalid or has already been used.')
  end
end
