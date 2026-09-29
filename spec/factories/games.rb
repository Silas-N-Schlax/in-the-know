# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    host factory: :user
    player_cap { 12 }
    round_count { 3 }
    rotations_per_round { 3 }
    imposter_min { 1 }
    imposter_max { 1 }
    category_mode { :fixed }
    category { 'Food & Drink' }
    pacing { :manual }

    trait :in_progress do
      status { :in_progress }
    end
  end

  factory :player do
    game
    sequence(:name) { |n| "Player #{n}" }
  end
end
