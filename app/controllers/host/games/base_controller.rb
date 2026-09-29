# frozen_string_literal: true

module Host
  module Games
    # Actions the host takes on a running game. Each one checks the game is in the right state,
    # so a double click or two tabs can't push the game forward twice.
    class BaseController < Host::BaseController
      private

      def current_round
        @current_round ||= current_game.current_round
      end

      def back_to_game(alert: nil)
        redirect_to host_game_path(current_game), alert:
      end

      def require_round_status(*statuses)
        return if current_round && statuses.include?(current_round.status.to_sym)

        back_to_game(alert: 'The game already moved on.')
      end
    end
  end
end
