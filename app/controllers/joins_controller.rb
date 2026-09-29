# frozen_string_literal: true

class JoinsController < ApplicationController
  def new
    return redirect_to(play_path) if current_player && !current_player.game.finished?

    @join = JoinGameForm.new(code: params[:code])
  end

  def create
    @join = JoinGameForm.new(join_params)

    if @join.save
      remember_player(@join.player)
      redirect_to @join.player.avatar ? play_path : edit_play_avatar_path
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def join_params
    params.expect(join: %i[code name rejoin])
  end
end
