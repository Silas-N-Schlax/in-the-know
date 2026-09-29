# frozen_string_literal: true

# Decides what a phone shows. A backup phone takes turns for each of its players,
# so this also works out whose turn it is to hold the phone.
class PhoneScreenPresenter
  attr_reader :player

  delegate :game, to: :player
  delegate :current_round, to: :game

  def initialize(player)
    @player = player
  end

  def phase
    return :lobby if game.lobby?
    return :final if game.finished?
    return :removed if player.removed? && !player.backup?
    return :waiting unless current_round

    case current_round.status
    when 'revealing' then next_to_reveal ? :reveal : :waiting
    when 'voting' then next_to_vote ? :vote : :voted
    when 'finished' then :round_over
    else seat_out? ? :out : :discussing
    end
  end

  def partial
    "devices/screens/#{phase}"
  end

  def device_players
    @device_players ||= player.device_players
  end

  def backup?
    player.backup?
  end

  # The first player on this phone who hasn't seen their word yet.
  def next_to_reveal
    return @next_to_reveal if defined?(@next_to_reveal)

    @next_to_reveal = device_seats.find { |seat| seat.revealed_at.nil? }
  end

  # The first player on this phone who is still in and hasn't voted this trip.
  def next_to_vote
    return @next_to_vote if defined?(@next_to_vote)

    voted = current_round.ballots.for_rotation(current_round.current_rotation).pluck(:voter_seat_id)
    @next_to_vote = device_seats.find { |seat| seat.playing? && voted.exclude?(seat.id) }
  end

  def vote_choices
    current_round.seats.playing.includes(:player).order('players.name')
  end

  def own_seat
    @own_seat ||= device_seats.find { |seat| seat.player_id == player.id }
  end

  def seat_out?
    backup? ? device_seats.none?(&:playing?) : !own_seat&.playing?
  end

  def leaderboard
    LeaderboardPresenter.new(game)
  end

  private

  def device_seats
    @device_seats ||= begin
      seats = current_round.seats.includes(:player).index_by(&:player_id)
      device_players.filter_map { |device_player| seats[device_player.id] }
    end
  end
end
