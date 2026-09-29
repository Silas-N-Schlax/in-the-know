# frozen_string_literal: true

module Host
  module Games
    # Deleting a game for good, after typing its code and confirming it can't be undone.
    class DeletionsController < BaseController
      def new
        @deletion = DeleteGameForm.new(game: current_game)
        render layout: 'modal'
      end

      def create
        @deletion = DeleteGameForm.new(game: current_game, **deletion_params)

        if @deletion.save
          redirect_to host_games_path(tab: current_game.finished? ? 'finished' : nil),
                      notice: "Game #{current_game.code} was deleted.", status: :see_other
        else
          render :new, layout: 'modal', status: :unprocessable_content
        end
      end

      private

      def deletion_params
        params.expect(delete_game: %i[code confirmed]).to_h.symbolize_keys
      end
    end
  end
end
