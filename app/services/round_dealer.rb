# frozen_string_literal: true

# Starts a new round: picks the word and a random number of imposters, and gives everyone a seat.
class RoundDealer
  def initialize(game)
    @game = game
  end

  def deal!
    players = @game.active_players.where.not(avatar: nil).to_a
    entry = pick_entry

    Round.transaction do
      round = @game.rounds.create!(number: next_number, word: entry.word, category: entry.category,
                                   imposter_hint: entry.imposter_hint, status: :revealing)
      seat_players(round, players)
      round
    end
  end

  private

  def next_number
    (@game.rounds.maximum(:number) || 0) + 1
  end

  # Random within the host's range, lowered if fewer people joined than the range expects.
  def imposter_count(player_count)
    high = [@game.imposter_max, Game.max_imposters_for(player_count)].min.clamp(1..)
    low = [@game.imposter_min, high].min
    rand(low..high)
  end

  def seat_players(round, players)
    imposters = players.sample(imposter_count(players.size))
    now = Time.current
    rows = players.map do |player|
      role = imposters.include?(player) ? 'imposter' : 'insider'
      { round_id: round.id, player_id: player.id, role:, created_at: now, updated_at: now }
    end
    Seat.insert_all!(rows)
  end

  def pick_entry
    used = @game.rounds.pluck(:word)
    category = @game.category_random? ? random_category(used) : @game.category

    difficulties = @game.difficulties

    WordBank.pick(category:, except: used, difficulties:) ||
      WordBank.pick(except: used, difficulties:) ||
      WordBank.pick(difficulties:) ||
      WordBank.pick
  end

  def random_category(used)
    WordBank.categories.shuffle.find { |category| WordBank.pick(category:, except: used, difficulties: @game.difficulties) }
  end
end
