module BP
  # The bitbang I2C protocol for the BusPirate.
  class I2C
    ACK  = 0x00
    NACK = 0x01

    SPEED_100 = 0x62
    POWER_ON  = 0x48
    PULLUP_ON = 0x44
    START     = 0x02
    STOP      = 0x03
    WRITE     = 0x10

    def initialize(controller, options = {})
      @controller = controller
      @controller.tx(POWER_ON | PULLUP_ON)
      @controller.tx(SPEED_100)
    end

    def tx(address, *bytes)
      @controller.tx(START)

      # How many bytes?
      @controller.tx(WRITE | bytes.length)

      # The I2C protocol specifies that the device address is left shifted
      # one bit.
      @controller.tx(address << 1, ACK)

      # Send each byte and ensure they are ACKed.
      bytes.each {|byte| @controller.tx(byte, ACK) }

      @controller.tx(STOP)
    end
  end
end
