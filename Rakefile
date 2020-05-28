# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Planner::Application.load_tasks

if %w[development test].include? Rails.env
  task(:default).clear
  task fast: ['spec:controllers', 'spec:helpers', 'spec:mailers', 'spec:models', 'spec:presenters']
  task slow: ['spec:features']
end
