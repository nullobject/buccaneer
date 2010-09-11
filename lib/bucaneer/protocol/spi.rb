module Bucaneer::Protocol
  # SPI bitbang on the BusPirate:
  #   http://dangerousprototypes.com/docs/SPI_(binary)
  #
  # SPI protocol:
  #   http://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
  class SPI
    SPI_MODE = 0x01

    SET_CS     = 0x02
    BULK_WRITE = 0x10

    ENABLE = 0x01

    CHUNK_SIZE = 16

    def initialize(controller, options = {})
      @controller = controller
      enter_spi_mode
    end

    def tx(*bytes)
      bytes.flatten!

      set_cs(false)

      bytes.to_enum.each_slice(CHUNK_SIZE) do |chunk|
        start_bulk_write(chunk.length)
        chunk.each {|byte| @controller.tx(byte, byte) }
      end

      set_cs(true)
    end

  private
    def set_cs(enable)
      mask  = SET_CS
      mask |= ENABLE if enable
      @controller.tx(mask)
    end

    def start_bulk_write(length)
      @controller.tx(BULK_WRITE | (length - 1))
    end

    def enter_spi_mode
      @controller.serial_port.puts SPI_MODE.chr
      sleep Bucaneer::BusPirate::TIMEOUT
      response = @controller.serial_port.read(4)
      raise "failed to enter SPI mode" unless response == "SPI1"
    end
  end
end
