# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid from the default factory' do
      expect(build(:user)).to be_valid
    end

    it 'requires a name once the account is set up' do
      user = build(:user, name: nil)

      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'does not require a name while the account is waiting for setup' do
      user = User.invite!(email: 'new@example.com') { |u| u.skip_invitation = true }

      expect(user).to be_persisted
      expect(user).to be_awaiting_setup
    end

    it 'limits names to 40 characters' do
      user = build(:user, name: 'a' * 41)

      expect(user).not_to be_valid
    end
  end

  describe '.search' do
    let!(:bea) { create(:user, name: 'Bea Bumble', email: 'bea@example.com') }
    let!(:cal) { create(:user, name: 'Cal Crumb', email: 'crumbs@example.com') }

    it 'matches names ignoring case' do
      expect(User.search('bumble')).to contain_exactly(bea)
    end

    it 'matches emails' do
      expect(User.search('CRUMBS')).to contain_exactly(cal)
    end

    it 'returns everyone for a blank query' do
      expect(User.search('')).to contain_exactly(bea, cal)
    end
  end
end
