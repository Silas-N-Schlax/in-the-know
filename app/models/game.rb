# frozen_string_literal: true

# One party session. The host sets it up, players join with the code, then it runs round by round.
class Game < ApplicationRecord
  include RefreshesGame

  CODE_ALPHABET = %w[A B C D E F G H J K L M N P Q R S T U V W X Y Z].freeze
  CODE_LENGTH = 4
  PLAYER_CAP_RANGE = (3..20)
  ROUND_COUNT_RANGE = (1..15)
  ROTATION_OPTIONS = [2, 3, 5, 7].freeze
  DISCUSSION_OPTIONS = [30, 60, 120, 180, 300].freeze
  PLAYERS_PER_IMPOSTER = 3
  IMPOSTER_LIMIT = 6
  RANDOM_CATEGORY = 'random'

  belongs_to :host, class_name: 'User', inverse_of: :hosted_games
  has_many :players, dependent: :destroy
  has_many :rounds, -> { order(:number) }, dependent: :destroy, inverse_of: :game

  enum :status, { lobby: 'lobby', in_progress: 'in_progress', finished: 'finished' }, default: :lobby
  enum :category_mode, { fixed: 'fixed', random: 'random' }, prefix: :category, default: :fixed
  enum :vote_visibility, { open: 'open', anonymous: 'anonymous' }, prefix: :votes, default: :open
  enum :pacing, { timed: 'timed', manual: 'manual' }, default: :timed

  normalizes :code, with: ->(code) { code.to_s.strip.upcase }

  before_validation :assign_code, on: :create

  validates :code, presence: true, length: { is: CODE_LENGTH }
  validates :player_cap, inclusion: { in: PLAYER_CAP_RANGE, message: 'must be between 3 and 20' }
  validates :round_count, inclusion: { in: ROUND_COUNT_RANGE, message: 'must be between 1 and 15' }
  validates :rotations_per_round, inclusion: { in: ROTATION_OPTIONS, message: 'must be 2, 3, 5 or 7' }
  validates :discussion_seconds, inclusion: { in: DISCUSSION_OPTIONS, message: 'is not one of the options' }
  validates :imposter_min, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :imposter_max, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :imposter_range_fits_player_cap
  validate :category_exists, if: :category_fixed?

  scope :open, -> { where.not(status: :finished) }

  def self.max_imposters_for(player_count)
    [player_count.to_i / PLAYERS_PER_IMPOSTER, IMPOSTER_LIMIT].min
  end

  def self.random_code
    Array.new(CODE_LENGTH) { CODE_ALPHABET[SecureRandom.random_number(CODE_ALPHABET.size)] }.join
  end

  def self.find_open_by_code(code)
    open.find_by(code: code.to_s.strip.upcase)
  end

  # The setup form offers categories and "Random each round" in one dropdown.
  def category_choice
    category_random? ? RANDOM_CATEGORY : category
  end

  def category_choice=(choice)
    if choice == RANDOM_CATEGORY
      self.category_mode = :random
      self.category = nil
    else
      self.category_mode = :fixed
      self.category = choice
    end
  end

  def joinable?
    lobby? && players.count < player_cap
  end

  def active_players
    players.active.order(:created_at)
  end

  def current_round
    rounds.last
  end

  def last_round?
    current_round.present? && current_round.number >= round_count
  end

  def ready_to_launch?
    active_players.where.not(avatar: nil).count >= PLAYER_CAP_RANGE.min
  end

  def leaderboard
    players.order(points: :desc, name: :asc)
  end

  private

  def assign_code
    return if code.present?

    self.code = loop do
      candidate = self.class.random_code
      break candidate unless self.class.open.exists?(code: candidate)
    end
  end

  def imposter_range_fits_player_cap
    return if imposter_min.blank? || imposter_max.blank?

    errors.add(:imposter_min, "can't be more than the maximum") if imposter_min > imposter_max

    limit = self.class.max_imposters_for(player_cap)
    errors.add(:imposter_max, "can be at most #{limit} for #{player_cap} players") if imposter_max > limit
  end

  def category_exists
    errors.add(:category, 'is not one of the categories') unless WordBank.category?(category)
  end
end
