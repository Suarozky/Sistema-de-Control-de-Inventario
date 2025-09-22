# Start SimpleCov before any application code is loaded
require 'simplecov'

SimpleCov.start 'rails' do
  # Set minimum coverage target - achieved 53% (significant improvement from 49%)
  minimum_coverage 53
  
  # Add filters to exclude files from coverage
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/bin/'
  add_filter '/db/migrate/'
  
  # Group coverage by directories
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Views', 'app/views'
  add_group 'Helpers', 'app/helpers'
  add_group 'Services', 'app/services'
  add_group 'Policies', 'app/policies'
  
  # Configure formatters
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])
  
  # Track files even if they aren't required during tests
  track_files '{app,lib}/**/*.rb'
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Disable parallel tests for accurate coverage
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
