# frozen_string_literal: true

class AddLastVoteToRounds < ActiveRecord::Migration[8.1]
  def change
    add_column :rounds, :last_vote_outcome, :string
    add_reference :rounds, :last_voted_out_seat, foreign_key: { to_table: :seats }
  end
end
