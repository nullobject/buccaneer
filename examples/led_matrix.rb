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
  # Set the number of LED matricies.
  def set_matrix_count(spi, n)
    spi.tx([0x25, n])
  end

  # Matrix pixels are packed RRRGGGBB.
  def matrix_set_buffer(spi, data)
    spi.tx(data)
  end

  # Generate some randomly filled buffers. NOTE: Due to a bug in LED matrix
  # firmware v4, the byte 0x25 (%) cannot be used as a color. This is because
  # it is the same control byte with tells the LED matrix how many chained
  # devices there are.
  array = 0.upto(256).map do |i|
    Array.new(MATRIX_SIZE) { rand(256) }
  end

  while $running do
    set_matrix_count(spi, 1)

    array.each do |data|
      break unless $running
      matrix_set_buffer(spi, data)
      sleep 0.125
    end
  end
end
