# frozen_string_literal: true

# The word list moved to fewer, broader categories. Point existing games and rounds at the new names.
class RenameOldWordCategories < ActiveRecord::Migration[8.1]
  RENAMES = {
    'Things You Can Eat' => 'Food & Drink',
    'Around the House' => 'Everyday',
    'Things You Wear' => 'Everyday',
    'Getting Around' => 'Everyday',
    'Out in the World' => 'Places & Travel',
    'Animals and Nature' => 'Animals & Nature',
    'Sports and Games' => 'Sports & Games',
    'Jobs and People' => 'People & Jobs',
    'Pop Culture and Fun' => 'Pop Culture & Fun',
    'Science and Space' => 'Math & Science',
    'Holidays and Celebrations' => 'Holidays & Events',
    'Music and Arts' => 'Music & Arts'
  }.freeze

  def up
    RENAMES.each do |old_name, new_name|
      execute "UPDATE games SET category = #{quote(new_name)} WHERE category = #{quote(old_name)}"
      execute "UPDATE rounds SET category = #{quote(new_name)} WHERE category = #{quote(old_name)}"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def quote(value) = connection.quote(value)
end
