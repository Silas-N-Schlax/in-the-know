# frozen_string_literal: true

module Host
  module Games
    class LaunchesController < BaseController
      def create
        return back_to_game(alert: 'This game already started.') unless current_game.lobby?
        return back_to_game(alert: 'Need at least 3 players with animals picked.') unless current_game.ready_to_launch?

        current_game.with_lock do
          current_game.in_progress!
          RoundDealer.new(current_game).deal!
        end
        back_to_game
      end
    end
  end
end
