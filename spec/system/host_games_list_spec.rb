# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Host games list', type: :system do
  let(:host) { create(:user) }

  before { sign_in host }

  it 'keeps finished games in their own tab, newest finished first' do
    create(:game, host:, code: 'OPEN')
    create(:game, host:, code: 'OLDR', status: :finished, finished_at: 2.days.ago)
    create(:game, host:, code: 'NEWR', status: :finished, finished_at: 1.hour.ago)

    visit host_games_path

    expect(page).to have_content('OPEN')
    expect(page).to have_no_content('OLDR')

    click_on 'Finished'

    expect(page).to have_no_content('OPEN')
    expect(page.text.index('NEWR')).to be < page.text.index('OLDR')
  end

  it 'records when a game finishes' do
    game = create(:game, host:, status: :in_progress)

    game.finished!

    expect(game.reload.finished_at).to be_within(5.seconds).of(Time.current)
  end
end
