# frozen_string_literal: true

# Decides what the shared host screen shows for the game's current state.
class HostScreenPresenter
  attr_reader :game

  delegate :current_round, to: :game

  def initialize(game, view)
    @game = game
    @view = view
  end

  def phase
    return :lobby if game.lobby?
    return :final if game.finished?

    current_round.status.to_sym
  end

  def partial
    "host/games/screens/#{phase}"
  end

  def join_url
    @view.new_join_url(code: game.code)
  end

  def join_qr_svg
    RQRCode::QRCode.new(join_url).as_svg(module_size: 6, use_path: true, viewbox: true, svg_attributes: { class: 'qr__code', role: 'img', 'aria-label': 'QR code to join' }).html_safe # rubocop:disable Rails/OutputSafety
  end

  def lobby_players
    game.players.order(:created_at)
  end

  def round_label
    "Round #{current_round.number} of #{game.round_count}"
  end

  def rotation_label
    "Trip #{current_round.current_rotation} of #{game.rotations_per_round}"
  end

  def category_label
    current_round.category
  end

  def leaderboard
    LeaderboardPresenter.new(game)
  end
end
