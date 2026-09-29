# frozen_string_literal: true

class AddDifficultiesToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :difficulties, :integer, array: true, null: false, default: [0, 1, 2]
  end
end
