# frozen_string_literal: true

module Host
  module Games
    # Starts discussion: the first trip once reveals are done (or the host moves on without stragglers),
    # or the next trip after a vote's result has been shown.
    class RotationsController < BaseController
      before_action { require_round_status(:revealing, :reviewing) }

      def create
        current_round.with_lock do
          current_round.increment(:current_rotation) if current_round.reviewing?
          current_round.start_discussion!
        end
        back_to_game
      end
    end
  end
end
