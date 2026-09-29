# frozen_string_literal: true

module Host
  class GamesController < BaseController
    TABS = %w[active finished].freeze

    def index
      @tab = TABS.include?(params[:tab]) ? params[:tab] : 'active'
      games = current_user.hosted_games.includes(:players)
      @games = @tab == 'finished' ? games.recently_finished_first : games.open.newest_first
    end

    def new
      @game = current_user.hosted_games.new(category: WordBank.categories.first)
    end

    def create
      @game = current_user.hosted_games.new(game_params)

      if @game.save
        redirect_to host_game_path(@game)
      else
        render :new, status: :unprocessable_content
      end
    end

    def show
      @screen = HostScreenPresenter.new(current_game, view_context)
    end

    private

    def game_params
      params.expect(game: %i[player_cap round_count rotations_per_round imposter_min imposter_max
                             category_choice reveal_on_vote_out vote_visibility pacing discussion_seconds])
    end
  end
end
