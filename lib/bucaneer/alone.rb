rc = "#{ENV['HOME']}/.rubyrc"
load(rc) if File.exist?(rc)

require 'rubygems'
require 'bundler'

envs = [:default]
envs << ENV["BUCANEER_ENV"].downcase.to_sym if ENV["BUCANEER_ENV"]
Bundler.setup(*envs)

path = File.join(File.expand_path(File.dirname(__FILE__)), '..')
$LOAD_PATH.unshift(path)

require 'bucaneer'
