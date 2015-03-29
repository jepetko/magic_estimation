namespace :db do

  desc 'database tasks'

  task :create_story_points => :environment do
    desc 'creates story points in points table: 1,2,3,5,8, ... 100'

    Point.delete_all
    [1,2,3,5,8,13,21,34,55,89].each do |value|
      p = Point.new(value: value)
      p.save!
      puts "Story point #{value} created."
    end
  end

  task :create_default_users => :environment do
    desc 'creates default users admin, bob and jeff'

    admin = User.new(name: 'boss', password: 'boss', password_confirmation: 'boss', role: 'admin')
    admin.save!
    puts 'User admin created.'

    bob = User.new(name: 'bob', password: 'bob', password_confirmation: 'bob', role: 'member')
    bob.save!
    puts 'User bob created.'

    jeff = User.new(name: 'jeff', password: 'jeff', password_confirmation: 'jeff', role: 'member')
    jeff.save!
    puts 'User jeff created.'
  end
end