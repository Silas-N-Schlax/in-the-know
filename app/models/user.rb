# frozen_string_literal: true

# A host account. Only super admins create users, handing them a one-time setup link.
class User < ApplicationRecord
  NAME_MAX_LENGTH = 40

  devise :invitable, :database_authenticatable, :rememberable, :validatable

  enum :role, { admin: 'admin', super_admin: 'super_admin' }, validate: true

  has_many :hosted_games, class_name: 'Game', foreign_key: :host_id, inverse_of: :host, dependent: :destroy

  validates :name, presence: true, unless: :awaiting_setup?
  validates :name, length: { maximum: NAME_MAX_LENGTH }

  scope :search, lambda { |query|
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where('name ILIKE :pattern OR email ILIKE :pattern', pattern:)
  }

  def awaiting_setup?
    invitation_token.present? && invitation_accepted_at.nil?
  end

  # Invites skip full validation, so check the email here before creating the account.
  def valid_for_invite?
    validate
    errors.delete(:password)
    errors.delete(:name)
    errors.empty?
  end

  def display_name
    name.presence || email
  end
end
