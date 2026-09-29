# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing users', type: :system do
  let(:super_admin) { create(:user, :super_admin) }

  before { sign_in super_admin }

  it 'searches users by name or email' do
    create(:user, name: 'Bea Bumble', email: 'bea@example.com')
    create(:user, name: 'Cal Crumb', email: 'cal@example.com')

    visit admin_users_path
    fill_in 'Search', with: 'bumble'
    click_on 'Search'

    expect(page).to have_content('Bea Bumble')
    expect(page).to have_no_content('Cal Crumb')
  end

  it 'creates a user and shows a one-time setup link' do
    visit admin_users_path
    click_on 'Add user'
    fill_in 'Email', with: 'newhost@example.com'
    choose 'Admin'
    click_on 'Create user'

    expect(page).to have_content('newhost@example.com')
    expect(page).to have_content('Setup link')
    expect(page).to have_field('setup_link', with: /invitation_token=/)
  end

  it 'shows an error when the email is invalid or taken' do
    create(:user, email: 'taken@example.com')

    visit new_admin_user_path
    fill_in 'Email', with: 'taken@example.com'
    click_on 'Create user'

    expect(page).to have_content('has already been taken')
  end

  it "changes a user's role" do
    user = create(:user, name: 'Dee Dough')

    visit admin_users_path
    within(data_test(user)) { click_on 'Edit' }
    choose 'Super admin'
    click_on 'Save'

    expect(page).to have_content('Dee Dough was updated')
    expect(user.reload).to be_super_admin
  end

  it 'generates a fresh setup link for a user who has not finished setup' do
    pending_user = User.invite!(email: 'late@example.com') { |u| u.skip_invitation = true }

    visit admin_user_path(pending_user)
    click_on 'New setup link'

    expect(page).to have_field('setup_link', with: /invitation_token=/)
  end

  it 'keeps regular admins out' do
    sign_in create(:user)

    visit admin_users_path

    expect(page).to have_current_path(host_games_path)
    expect(page).to have_content('Only super admins can do that.')
  end
end
