# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discussion timer', :js, type: :system do
  let(:host) { create(:user) }
  let(:game) { create(:game, :in_progress, host:, pacing: :timed, discussion_seconds: 120) }
  let(:round) { create(:round, game:, status: :revealing) }

  before do
    create_list(:seat, 3, round:)
    sign_in host
  end

  it 'counts down in minutes and seconds when the page loads mid-discussion' do
    round.start_discussion!

    visit host_game_path(game)

    expect(page).to have_css('.timer__clock', text: /\A[12]:\d\d\z/)
  end

  it 'counts down when discussion starts while the host screen is open' do
    visit host_game_path(game)
    expect(page).to have_content('Everyone, check your phone')
    wait_for_stream_connection

    round.start_discussion!

    expect(page).to have_css('.timer__clock', text: /\A[12]:\d\d\z/)
    expect(page).to have_no_content('NaN')
  end
end
