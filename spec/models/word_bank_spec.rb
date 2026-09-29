# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordBank do
  it 'loads entries with a word, category, lang and imposter hint' do
    entry = WordBank.entries.first

    expect(entry.word).to be_present
    expect(entry.category).to be_present
    expect(entry.lang).to eq('en')
    expect(entry.imposter_hint).to be_present
    expect(entry.difficulty).to be_in([0, 1, 2])
  end

  it 'has words at every difficulty' do
    expect(WordBank.entries.map(&:difficulty).uniq).to contain_exactly(0, 1, 2)
  end

  it 'lists the categories' do
    expect(WordBank.categories).to include('Food & Drink', 'Everyday')
  end

  it 'has no duplicate words within a category' do
    WordBank.entries.group_by(&:category).each_value do |entries|
      words = entries.map { |entry| entry.word.downcase }
      expect(words).to eq(words.uniq)
    end
  end

  describe '.pick' do
    it 'picks from the given category, skipping words already used' do
      used = WordBank.entries.select { |e| e.category == 'Everyday' }.map(&:word)
      unused = used.pop

      expect(WordBank.pick(category: 'Everyday', except: used).word).to eq(unused)
    end

    it 'only picks the chosen difficulties' do
      picks = Array.new(30) { WordBank.pick(difficulties: [2]) }

      expect(picks.map(&:difficulty).uniq).to eq([2])
    end

    it 'returns nil when a category is used up' do
      used = WordBank.entries.select { |e| e.category == 'Everyday' }.map(&:word)

      expect(WordBank.pick(category: 'Everyday', except: used)).to be_nil
    end
  end
end
