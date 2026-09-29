# frozen_string_literal: true

class CreateRoundsSeatsAndBallots < ActiveRecord::Migration[8.1]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :word, null: false
      t.string :category, null: false
      t.string :imposter_hint, null: false
      t.string :status, null: false, default: 'revealing'
      t.integer :current_rotation, null: false, default: 1
      t.datetime :discussion_ends_at
      t.string :winner

      t.timestamps
    end
    add_index :rounds, %i[game_id number], unique: true

    create_table :seats do |t|
      t.references :round, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :role, null: false
      t.string :status, null: false, default: 'playing'
      t.integer :out_in_rotation
      t.datetime :revealed_at
      t.integer :points_earned, null: false, default: 0

      t.timestamps
    end
    add_index :seats, %i[round_id player_id], unique: true

    create_table :ballots do |t|
      t.references :round, null: false, foreign_key: true
      t.integer :rotation, null: false
      t.references :voter_seat, null: false, foreign_key: { to_table: :seats }
      t.references :target_seat, foreign_key: { to_table: :seats }

      t.timestamps
    end
    add_index :ballots, %i[round_id rotation voter_seat_id], unique: true, name: 'index_ballots_one_per_voter'
  end
end
