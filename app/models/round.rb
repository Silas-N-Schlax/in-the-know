# frozen_string_literal: true

# One word, one set of imposters. A round goes: revealing → (discussing → voting → reviewing) per trip → finished.
class Round < ApplicationRecord
  include RefreshesGame

  belongs_to :game, inverse_of: :rounds
  has_many :seats, dependent: :destroy
  has_many :ballots, dependent: :destroy
  belongs_to :last_voted_out_seat, class_name: 'Seat', optional: true

  enum :status, {
    revealing: 'revealing', discussing: 'discussing', voting: 'voting', reviewing: 'reviewing', finished: 'finished'
  }, default: :revealing
  enum :winner, { imposters: 'imposters', insiders: 'insiders' }, prefix: :won_by
  enum :last_vote_outcome, { voted_out: 'voted_out', tied: 'tied', skipped: 'skipped' }, prefix: :last_vote

  validates :number, :word, :category, :imposter_hint, presence: true

  def last_rotation?
    current_rotation >= game.rotations_per_round
  end

  def everyone_revealed?
    seats.where(revealed_at: nil).none?
  end

  def voters
    seats.playing
  end

  def everyone_voted?
    ballots.for_rotation(current_rotation).count >= voters.count
  end

  # Starts a trip's discussion, with a deadline when the game is timed.
  def start_discussion!
    update!(status: :discussing, discussion_ends_at: (Time.current + game.discussion_seconds.seconds if game.timed?))
  end

  def seconds_left
    return unless discussion_ends_at

    [(discussion_ends_at - Time.current).ceil, 0].max
  end
end
