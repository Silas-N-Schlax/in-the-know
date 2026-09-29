# frozen_string_literal: true

module Host
  module Games
    # Deals the next round once the current one is over.
    class RoundsController < BaseController
      before_action { require_round_status(:finished) }

      def create
        return back_to_game(alert: 'That was the last round.') if current_game.finished? || current_game.last_round?

        current_game.with_lock { RoundDealer.new(current_game).deal! if current_round.finished? }
        back_to_game
      end
    end
  end
end
