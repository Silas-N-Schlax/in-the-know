# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.references :handler, foreign_key: { to_table: :players }
      t.string :name, null: false
      t.string :avatar
      t.string :token
      t.boolean :backup, null: false, default: false
      t.string :status, null: false, default: 'active'
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    add_index :players, 'game_id, lower(name)', unique: true, name: 'index_players_on_game_and_name'
    add_index :players, %i[game_id avatar], unique: true, where: 'avatar IS NOT NULL'
    add_index :players, :token, unique: true, where: 'token IS NOT NULL'
  end
end
