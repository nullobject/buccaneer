module BP
  # I2C bitbang on the BusPirate:
  #   http://dangerousprototypes.com/docs/I2C_(binary)
  #
  # I2C protocol:
  #   http://en.wikipedia.org/wiki/I²C
  class I2C
    ACK  = 0x00
    NACK = 0x01

    # BusPirate bitbang commands.
    BP_SPEED_100  = 0x62
    BP_POWER_ON   = 0x48
    BP_PULLUPS_ON = 0x44
    BP_START      = 0x02
    BP_STOP       = 0x03
    BP_BULK_WRITE = 0x10

    I2C_WRITE = 0x00
    I2C_READ  = 0x01

    def initialize(controller, options = {})
      @controller = controller
      @controller.tx(BP_POWER_ON | BP_PULLUPS_ON)
      @controller.tx(BP_SPEED_100)
    end

    def tx(address, *bytes)
      @controller.tx(BP_START)

      # How many bytes?
      @controller.tx(BP_BULK_WRITE | bytes.length)

      # Send the 7-bit device address followed by the write bit.
      @controller.tx((address << 1) | I2C_WRITE, ACK)

      # Send the bytes.
      bytes.each {|byte| @controller.tx(byte, ACK) }

      @controller.tx(BP_STOP)
    end
  end
end
