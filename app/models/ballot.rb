# frozen_string_literal: true

# One vote in one trip around the table. No target means Skip.
class Ballot < ApplicationRecord
  include RefreshesGame

  belongs_to :round
  belongs_to :voter_seat, class_name: 'Seat'
  belongs_to :target_seat, class_name: 'Seat', optional: true

  validates :rotation, presence: true
  validate :voter_still_in
  validate :target_still_in, if: :target_seat

  scope :for_rotation, ->(rotation) { where(rotation:) }

  def skip?
    target_seat_id.nil?
  end

  private

  def game
    round.game
  end

  def voter_still_in
    errors.add(:base, "You're out, so you can't vote.") unless voter_seat&.playing?
  end

  def target_still_in
    errors.add(:base, "#{target_seat.name} is already out.") unless target_seat.playing?
    errors.add(:base, "You can't vote for yourself.") if target_seat_id == voter_seat_id
  end
end
