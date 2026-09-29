# frozen_string_literal: true

module Host
  module Players
    # In the lobby a removal deletes the player. Mid-game it counts like being voted out,
    # for just this round or for the rest of the game.
    class RemovalsController < BaseController
      def new
        render layout: 'modal'
      end

      def create
        if @game.lobby?
          remove_from_lobby
        else
          PlayerRemoval.new(@player, rest_of_game: params[:scope] == 'game').remove!
          back_to_game(notice: "#{@player.name} was removed.")
        end
      end

      private

      def remove_from_lobby
        return back_to_game(alert: "Remove the players on #{@player.name}'s phone first.") if @player.handled_players.any?

        @player.destroy!
        back_to_game(notice: "#{@player.name} was removed.")
      end
    end
  end
end
