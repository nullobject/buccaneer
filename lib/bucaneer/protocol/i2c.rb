module Bucaneer::Protocol
  # I2C bitbang on the BusPirate:
  #   http://dangerousprototypes.com/docs/I2C_(binary)
  #
  # I2C protocol:
  #   http://en.wikipedia.org/wiki/I²C
  class I2C
    I2C_MODE      = 0x02

    SET_SPEED     = 0x62
    START         = 0x02
    STOP          = 0x03
    BULK_WRITE    = 0x10

    I2C_WRITE_BIT = 0x00
    I2C_READ_BIT  = 0x01

    ACK           = 0x00
    NACK          = 0x01

    CHUNK_SIZE    = 16

    def initialize(controller, options = {})
      @controller = controller
      enter_i2c_mode
      @controller.tx(SET_SPEED)
    end

    def tx(address, *bytes)
      bytes.flatten!

      @controller.tx(START)

      bytes.to_enum.each_slice(CHUNK_SIZE) do |chunk|
        start_bulk_write(chunk.length + 1)
        @controller.tx((address << 1) | I2C_WRITE_BIT, ACK)
        chunk.each {|byte| @controller.tx(byte, ACK) }
      end

      @controller.tx(STOP)
    end

  private

    def start_bulk_write(length)
      @controller.tx(BULK_WRITE | (length - 1))
    end

    def enter_i2c_mode
      @controller.serial_port.puts I2C_MODE.chr
      sleep Bucaneer::BusPirate::TIMEOUT
      response = @controller.serial_port.read(4)
      raise "failed to enter I2C mode" unless response == "I2C1"
    end
  end
end
