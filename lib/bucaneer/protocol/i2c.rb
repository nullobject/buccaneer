module Bucaneer::Protocol
  # I²C bitbang on the BusPirate:
  #   http://dangerousprototypes.com/docs/I2C_(binary)
  #
  # I²C protocol:
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
      @controller.set_peripherals(options)
      set_speed
    end

    def set_speed
      puts "setting i2c speed..."
      @controller.tx(SET_SPEED)
      puts "ok"
    end

    def tx(address, *bytes)
      bytes.flatten!

      @controller.tx(START)

      bytes.to_enum.each_slice(CHUNK_SIZE) do |chunk|
        start_bulk_write(chunk.length + 1)

        unless @controller.tx((address << 1) | I2C_WRITE_BIT) == ACK
          puts "failed to ACK byte"
        end

        chunk.each do |byte|
          unless @controller.tx(byte) == ACK
            puts "failed to ACK byte"
          end
        end
      end

      @controller.tx(STOP)
    end

  private

    def start_bulk_write(length)
      unless @controller.tx(BULK_WRITE | (length - 1)) == Bucaneer::BusPirate::SUCCESS
        raise "failed to start bulk write"
      end
    end

    def enter_i2c_mode
      puts "entering i2c mode..."
      @controller.serial_port.write I2C_MODE.chr
      sleep 0.1
      response = @controller.serial_port.read(4)
      unless response == "I2C1"
        raise "failed to enter I2C mode"
      end
      puts "ok"
    end
  end
end
