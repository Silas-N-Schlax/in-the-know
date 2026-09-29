# frozen_string_literal: true

# The one account that exists out of the box. Change the password after your first sign in.
User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.name = 'Sir Knows-a-Lot'
  user.role = :super_admin
  user.password = 'password'
  user.password_confirmation = 'password'
end

puts 'Seeded super admin: admin@example.com / password (Sir Knows-a-Lot)'
