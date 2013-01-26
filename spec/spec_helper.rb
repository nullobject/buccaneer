require "rspec"
require "simplecov"

SimpleCov.start

require "buccaneer"

RSpec.configure do |config|
  config.mock_with :rspec
end
