# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.string :code, null: false
      t.string :status, null: false, default: 'lobby'
      t.integer :player_cap, null: false, default: 12
      t.integer :round_count, null: false, default: 5
      t.integer :rotations_per_round, null: false, default: 3
      t.integer :imposter_min, null: false, default: 1
      t.integer :imposter_max, null: false, default: 1
      t.string :category_mode, null: false, default: 'fixed'
      t.string :category
      t.boolean :reveal_on_vote_out, null: false, default: true
      t.string :vote_visibility, null: false, default: 'open'
      t.string :pacing, null: false, default: 'timed'
      t.integer :discussion_seconds, null: false, default: 120

      t.timestamps
    end

    add_index :games, :code, unique: true, where: "status <> 'finished'", name: 'index_games_on_code_while_open'
  end
end
