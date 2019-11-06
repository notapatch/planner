namespace :db do
  desc 'db:create db:migrate db:seed db:test:prepare'
  task setup_planner: :environment do
    Rails.logger.level = :info

    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
end
