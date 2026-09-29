# frozen_string_literal: true

module Host
  module Players
    class BaseController < Host::BaseController
      before_action :set_player

      private

      def set_player
        @player = Player.joins(:game).where(games: { host_id: current_user.id }).find(params[:player_id])
        @game = @player.game
      end

      def back_to_game(**flash)
        redirect_to host_game_path(@game), flash
      end
    end
  end
end
