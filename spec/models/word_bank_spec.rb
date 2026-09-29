# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordBank do
  it 'loads entries with a word, category, lang and imposter hint' do
    entry = WordBank.entries.first

    expect(entry.word).to be_present
    expect(entry.category).to be_present
    expect(entry.lang).to eq('en')
    expect(entry.imposter_hint).to be_present
  end

  it 'lists the categories' do
    expect(WordBank.categories).to include('Things You Can Eat', 'Around the House')
  end

  it 'has no duplicate words within a category' do
    WordBank.entries.group_by(&:category).each_value do |entries|
      words = entries.map { |entry| entry.word.downcase }
      expect(words).to eq(words.uniq)
    end
  end

  describe '.pick' do
    it 'picks from the given category, skipping words already used' do
      used = WordBank.entries.select { |e| e.category == 'Around the House' }.map(&:word)
      unused = used.pop

      expect(WordBank.pick(category: 'Around the House', except: used).word).to eq(unused)
    end

    it 'returns nil when a category is used up' do
      used = WordBank.entries.select { |e| e.category == 'Around the House' }.map(&:word)

      expect(WordBank.pick(category: 'Around the House', except: used)).to be_nil
    end
  end
end
