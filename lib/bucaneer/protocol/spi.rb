module Bucaneer::Protocol
  # The bitbang SPI protocol for the BusPirate.
  class SPI
    SPI_POWER_ON  = 0x48
    SPI_PULLUP_ON = 0x44

    def initialize(controller, options = {})
      @controller = controller
      @controller.send(SPI_POWER_ON | SPI_PULLUP_ON)
    end

    def send(address, *bytes)
      # TODO: send the bytes.
    end
  end
end
