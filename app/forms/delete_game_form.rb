# frozen_string_literal: true

# The "are you sure" for deleting a game: type the game's code to prove you mean this one.
class DeleteGameForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :code, :string

  attr_reader :game

  validate :code_matches

  def initialize(game:, **attributes)
    @game = game
    super(**attributes)
  end

  def save
    return false unless valid?

    GameDeletion.new(game).delete!
    true
  end

  private

  def code_matches
    return if code.to_s.strip.casecmp?(game.code)

    errors.add(:code, "That code doesn't match this game.")
  end
end
