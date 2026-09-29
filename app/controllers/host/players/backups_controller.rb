# frozen_string_literal: true

module Host
  module Players
    # A backup phone gets passed around for people who don't have one.
    class BackupsController < BaseController
      def create
        return back_to_game(alert: "#{@player.name} is on someone else's phone.") if @player.handled?

        @player.update!(backup: true)
        back_to_game
      end

      def destroy
        if @player.handled_players.any?
          names = @player.handled_players.map(&:name).to_sentence
          return back_to_game(alert: "#{@player.name}'s phone is still looking after #{names}. Remove them first.")
        end

        @player.update!(backup: false)
        back_to_game
      end
    end
  end
end
