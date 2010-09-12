# LED matrix demo
# http://www.sparkfun.com/commerce/product_info.php?products_id=760

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
  def set_matrix_count(spi, n)
    spi.tx([0x25, n])
  end

  def matrix_set_buffer(spi, data)
    spi.tx(data)
  end

  array = 0.upto(256).map do |i|
    Array.new(MATRIX_SIZE) do
      n = 0
      begin
        n = rand(256)
      end until n != 0x25
      n
    end
  end

  set_matrix_count(spi, 1)

  while $running do
    array.each do |data|
      break unless $running
      matrix_set_buffer(spi, data)
#       sleep 0.125
    end
  end
end
