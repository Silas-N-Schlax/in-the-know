# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_29_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ballots", force: :cascade do |t|
    t.bigint "round_id", null: false
    t.integer "rotation", null: false
    t.bigint "voter_seat_id", null: false
    t.bigint "target_seat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["round_id", "rotation", "voter_seat_id"], name: "index_ballots_one_per_voter", unique: true
    t.index ["round_id"], name: "index_ballots_on_round_id"
    t.index ["target_seat_id"], name: "index_ballots_on_target_seat_id"
    t.index ["voter_seat_id"], name: "index_ballots_on_voter_seat_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.string "code", null: false
    t.string "status", default: "lobby", null: false
    t.integer "player_cap", default: 12, null: false
    t.integer "round_count", default: 5, null: false
    t.integer "rotations_per_round", default: 3, null: false
    t.integer "imposter_min", default: 1, null: false
    t.integer "imposter_max", default: 1, null: false
    t.string "category_mode", default: "fixed", null: false
    t.string "category"
    t.boolean "reveal_on_vote_out", default: true, null: false
    t.string "vote_visibility", default: "open", null: false
    t.string "pacing", default: "timed", null: false
    t.integer "discussion_seconds", default: 120, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finished_at"
    t.index ["code"], name: "index_games_on_code_while_open", unique: true, where: "((status)::text <> 'finished'::text)"
    t.index ["host_id", "finished_at"], name: "index_games_on_host_id_and_finished_at"
    t.index ["host_id"], name: "index_games_on_host_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "handler_id"
    t.string "name", null: false
    t.string "avatar"
    t.string "token"
    t.boolean "backup", default: false, null: false
    t.string "status", default: "active", null: false
    t.integer "points", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "game_id, lower((name)::text)", name: "index_players_on_game_and_name", unique: true
    t.index ["game_id", "avatar"], name: "index_players_on_game_id_and_avatar", unique: true, where: "(avatar IS NOT NULL)"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["handler_id"], name: "index_players_on_handler_id"
    t.index ["token"], name: "index_players_on_token", unique: true, where: "(token IS NOT NULL)"
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "number", null: false
    t.string "word", null: false
    t.string "category", null: false
    t.string "imposter_hint", null: false
    t.string "status", default: "revealing", null: false
    t.integer "current_rotation", default: 1, null: false
    t.datetime "discussion_ends_at"
    t.string "winner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_vote_outcome"
    t.bigint "last_voted_out_seat_id"
    t.index ["game_id", "number"], name: "index_rounds_on_game_id_and_number", unique: true
    t.index ["game_id"], name: "index_rounds_on_game_id"
    t.index ["last_voted_out_seat_id"], name: "index_rounds_on_last_voted_out_seat_id"
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "round_id", null: false
    t.bigint "player_id", null: false
    t.string "role", null: false
    t.string "status", default: "playing", null: false
    t.integer "out_in_rotation"
    t.datetime "revealed_at"
    t.integer "points_earned", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_seats_on_player_id"
    t.index ["round_id", "player_id"], name: "index_seats_on_round_id_and_player_id", unique: true
    t.index ["round_id"], name: "index_seats_on_round_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "name"
    t.string "role", default: "admin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
  end

  add_foreign_key "ballots", "rounds"
  add_foreign_key "ballots", "seats", column: "target_seat_id"
  add_foreign_key "ballots", "seats", column: "voter_seat_id"
  add_foreign_key "games", "users", column: "host_id"
  add_foreign_key "players", "games"
  add_foreign_key "players", "players", column: "handler_id"
  add_foreign_key "rounds", "games"
  add_foreign_key "rounds", "seats", column: "last_voted_out_seat_id"
  add_foreign_key "seats", "players"
  add_foreign_key "seats", "rounds"
end
