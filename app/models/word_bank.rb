# frozen_string_literal: true

# Every playable word lives in config/words.json as { word, category, lang, imposter_hint, difficulty }.
# Difficulty runs 0 (easy) to 2 (hard).
class WordBank
  PATH = Rails.root.join('config/words.json')

  Entry = Data.define(:word, :category, :lang, :imposter_hint, :difficulty)

  class << self
    def entries
      @entries ||= JSON.parse(PATH.read, symbolize_names: true).map { |attrs| Entry.new(**attrs) }.freeze
    end

    def categories
      @categories ||= entries.map(&:category).uniq.sort.freeze
    end

    def category?(name)
      categories.include?(name)
    end

    # A random entry from the category (or any category) at one of the difficulties, that isn't in `except`.
    def pick(category: nil, except: [], difficulties: nil)
      used = except.to_set(&:downcase)
      candidates = entries.reject { |entry| used.include?(entry.word.downcase) }
      candidates = candidates.select { |entry| entry.category == category } if category
      candidates = candidates.select { |entry| difficulties.include?(entry.difficulty) } if difficulties
      candidates.sample
    end
  end
end
