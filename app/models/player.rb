# frozen_string_literal: true

# Someone at the party. Players have no account; the token in their phone's cookie is who they are.
# A backup player's phone also looks after the players whose handler it is.
class Player < ApplicationRecord
  include RefreshesGame

  AVATARS = %w[
    otter fox axolotl capybara penguin frog owl hedgehog llama octopus
    flamingo sloth walrus koala narwhal platypus red_panda goose shark toucan
  ].freeze
  ANONYMOUS_AVATAR = 'raccoon'
  NAME_MAX_LENGTH = 16

  belongs_to :game
  belongs_to :handler, class_name: 'Player', optional: true, inverse_of: :handled_players
  has_many :handled_players, -> { order(:created_at) }, class_name: 'Player', foreign_key: :handler_id,
                                                        inverse_of: :handler, dependent: :nullify
  has_many :seats, dependent: :destroy

  enum :status, { active: 'active', removed: 'removed' }, default: :active

  has_secure_token :token

  normalizes :name, with: ->(name) { name.to_s.squish }

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validate :name_unique_in_game
  validates :avatar, inclusion: { in: AVATARS, message: 'is not one of the animals' }, allow_nil: true
  validates :avatar, uniqueness: { scope: :game_id, message: 'was just taken. Pick another.' }, allow_nil: true

  scope :named, ->(name) { where('lower(name) = ?', name.to_s.squish.downcase) }

  def self.available_avatars
    AVATARS - where.not(avatar: nil).pluck(:avatar)
  end

  def self.avatar_label(avatar)
    avatar.to_s.humanize.titleize
  end

  # Everyone this phone takes turns for: just this player, or a backup plus the players it looks after.
  def device_players
    [self, *(backup? ? handled_players : [])]
  end

  def handled?
    handler_id.present?
  end

  def avatar_label
    self.class.avatar_label(avatar)
  end

  def current_seat
    game.current_round&.seats&.find_by(player: self)
  end

  private

  def name_unique_in_game
    return if name.blank? || game.nil?

    others = game.players.named(name)
    others = others.where.not(id:) if persisted?
    errors.add(:name, 'is already in this game') if others.exists?
  end
end
