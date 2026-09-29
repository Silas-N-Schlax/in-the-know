# frozen_string_literal: true

# One player's part in one round: their role and whether they're still in.
class Seat < ApplicationRecord
  include RefreshesGame

  belongs_to :round
  belongs_to :player

  enum :role, { insider: 'insider', imposter: 'imposter' }, validate: true
  enum :status, { playing: 'playing', voted_out: 'voted_out', removed: 'removed' }, default: :playing

  delegate :name, :avatar, :avatar_label, to: :player

  def out?
    !playing?
  end

  def revealed?
    revealed_at.present?
  end

  # What this player sees on their reveal: the word, or the hint if they're an imposter.
  def secret
    imposter? ? round.imposter_hint : round.word
  end

  private

  def game
    round.game
  end
end
