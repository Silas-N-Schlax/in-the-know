# frozen_string_literal: true

module Host
  module Games
    # Ends the game early, e.g. when the party is winding down.
    class FinishesController < BaseController
      def create
        current_game.finished! unless current_game.finished?
        back_to_game
      end
    end
  end
end
