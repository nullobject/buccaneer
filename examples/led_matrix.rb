# LED matrix demo
# http://www.sparkfun.com/commerce/product_info.php?products_id=760

require 'bucaneer'

Bucaneer::BusPirate.connect(
  :dev     => '/dev/tty.usbserial-A7004HZe',
  :mode    => :spi,
  :power   => :on,
  :pullups => :on
) do |spi|
end
