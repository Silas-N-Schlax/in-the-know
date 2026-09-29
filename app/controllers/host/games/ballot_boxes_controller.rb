# frozen_string_literal: true

module Host
  module Games
    # Opening the ballot box starts the vote; closing it counts the votes, missing ones as Skip.
    class BallotBoxesController < BaseController
      before_action(only: :create) { require_round_status(:discussing) }
      before_action(only: :destroy) { require_round_status(:voting) }

      def create
        current_round.with_lock { current_round.voting! if current_round.discussing? }
        back_to_game
      end

      def destroy
        VoteTally.new(current_round).close!
        back_to_game
      end
    end
  end
end
