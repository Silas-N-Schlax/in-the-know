# frozen_string_literal: true

module GamesHelper
  def discussion_label(seconds)
    seconds < 60 ? "#{seconds}s" : "#{seconds / 60}m"
  end

  def category_options
    [['Random each round', Game::RANDOM_CATEGORY], *WordBank.categories.map { |category| [category, category] }]
  end

  def pill_options(values)
    values.map { |value| [value.to_s, value] }
  end
end
