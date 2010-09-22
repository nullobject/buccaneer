# LED matrix demo
#
# Order one from:
#   http://www.sparkfun.com/commerce/product_info.php?products_id=760

require 'rubygems'
require 'bundler/setup'

require 'bucaneer'

MATRIX_SIZE = 64

options = {
  :dev   => '/dev/tty.usbserial-A7004HZe',
  :mode  => :spi,
  :power => true
}

$running = true

trap("TERM") { stop }
trap("INT")  { stop }

def stop
  raise "forced close" unless $running
  puts "stopping..."
  $running = false
end

Bucaneer::BusPirate.connect(options) do |spi|
  # Generate some randomly filled buffers.
  array = 0.upto(256).map do |i|
    Array.new(MATRIX_SIZE) { rand(256) }
  end

  while $running do
    array.each do |data|
      break unless $running
      spi.tx(data)
      sleep 0.125
    end
  end
end
