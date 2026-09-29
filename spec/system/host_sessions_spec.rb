# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Host sessions', type: :system do
  let!(:host) { create(:user, name: 'Pat Host', email: 'pat@example.com', password: 'secret123') }

  it 'lets a host sign in from the home page and land on their games' do
    visit root_path
    click_on 'Host sign in'
    fill_in 'Email', with: 'pat@example.com'
    fill_in 'Password', with: 'secret123'
    click_on 'Sign in'

    expect(page).to have_current_path(host_games_path)
    expect(page).to have_content('Your games')
  end

  it 'lets a host sign out' do
    sign_in host

    visit host_games_path
    click_on 'Sign out'

    expect(page).to have_current_path(root_path)
    expect(page).to have_button('Join game')
  end

  it 'sends visitors to sign in before the host area' do
    visit host_games_path

    expect(page).to have_current_path(new_user_session_path)
  end
end
