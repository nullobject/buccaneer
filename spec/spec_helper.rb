require "rspec"
require "simplecov"

SimpleCov.start

require "bucaneer"

RSpec.configure do |config|
  config.mock_with :rspec
end
