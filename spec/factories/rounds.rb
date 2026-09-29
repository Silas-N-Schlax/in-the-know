# frozen_string_literal: true

FactoryBot.define do
  factory :round do
    game factory: %i[game in_progress]
    sequence(:number)
    word { 'Pancake' }
    category { 'Food & Drink' }
    imposter_hint { 'Flat and round' }
    status { :discussing }
  end

  factory :seat do
    round
    player { association :player, game: round.game }
    role { :insider }

    trait :imposter do
      role { :imposter }
    end
  end
end
