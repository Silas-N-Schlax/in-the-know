# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Pat Host' }
    sequence(:email) { |n| "host#{n}@example.com" }
    password { 'password123' }
    password_confirmation { password }
    role { :admin }

    trait :super_admin do
      name { 'Sam Super' }
      role { :super_admin }
    end
  end
end
