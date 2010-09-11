# LED matrix demo
# http://www.sparkfun.com/commerce/product_info.php?products_id=760

require 'bucaneer'

MATRIX_SIZE = 64

options = {
  :dev     => '/dev/tty.usbserial-A7004HZe',
  :mode    => :spi,
  :power   => :on,
  :pullups => :on
}

Bucaneer::BusPirate.connect(options) do |spi|
  def matrix_set_buffer(data)
    spi.tx(data)
  end

  data = Array.new(MATRIX_SIZE) { rand(256) }
  matrix_set_buffer(data)
end
