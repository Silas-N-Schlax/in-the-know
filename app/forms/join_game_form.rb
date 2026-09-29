# frozen_string_literal: true

# Handles the home screen: find the game by code, then either add a new player or,
# when the name is already taken and the player confirms it's them, move that player to this phone.
class JoinGameForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string
  attribute :name, :string
  attribute :rejoin, :boolean, default: false

  attr_reader :player

  validates :code, presence: true
  validates :name, presence: true, length: { maximum: Player::NAME_MAX_LENGTH }
  validate :game_is_open, if: -> { code.present? }

  def code=(value)
    super(value.to_s.strip.upcase)
  end

  def name=(value)
    super(value.to_s.squish)
  end

  def game
    return @game if defined?(@game)

    @game = Game.find_open_by_code(code)
  end

  # The existing player with this name, which is what a rejoin claims.
  def existing_player
    return unless game && name.present?

    @existing_player ||= game.players.named(name).first
  end

  def needs_rejoin_confirmation?
    errors.empty? && existing_player.present? && !rejoin
  end

  def save
    return false unless valid?
    return false if needs_rejoin_confirmation?

    rejoin && existing_player ? claim_existing_player : add_new_player
  end

  private

  def game_is_open
    return errors.add(:base, 'No open game has that code. Check the host screen.') unless game
    return if rejoin || existing_player
    return errors.add(:base, 'That game already started. Only players already in it can rejoin.') unless game.lobby?

    errors.add(:base, 'That game is full.') unless game.joinable?
  end

  def claim_existing_player
    existing_player.regenerate_token
    existing_player.update!(handler: nil)
    @player = existing_player
    true
  end

  def add_new_player
    @player = game.players.create(name:)
    return true if @player.persisted?

    @player.errors.each { |error| errors.add(error.attribute, error.message) }
    false
  rescue ActiveRecord::RecordNotUnique
    errors.add(:name, 'was just taken by someone else. Try another.')
    false
  end
end
