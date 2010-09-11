require 'serialport'

module Bucaneer
  class BusPirate
    DEFAULT_BAUD = 115200

    TIMEOUT   = 0.01
    MAX_TRIES = 40

    BITBANG_MODE = 0x00

    SET_PERIPHERALS = 0x40
    POWER_ON        = 0x08
    PULLUPS_ON      = 0x04
    AUX_ON          = 0x02
    CS_ON           = 0x01

    FAILURE = 0x00
    SUCCESS = 0x01

    attr_reader :serial_port, :protocol

    def self.connect(options = {})
      dev  = options.delete(:dev)
      mode = options.delete(:mode)
      baud = options.delete(:baud) || DEFAULT_BAUD

      raise "no device specified" unless dev
      raise "no mode specified"   unless mode

      serial_port = SerialPort.new(dev, baud)

      begin
        bus_pirate = Bucaneer::BusPirate.new(serial_port, mode, options)
        yield bus_pirate.protocol if block_given?
      ensure
        serial_port.close
      end
    end

    def initialize(serial_port, mode, options)
      @serial_port = serial_port
      set_mode(mode.to_sym, options)
    end

    def tx(byte, expected = SUCCESS)
      @serial_port.putc byte
      sleep TIMEOUT
      response = @serial_port.getc
      raise "failed to send data" unless response == expected
      response
    end

    def enter_bitbang_mode
      tries = 0
      begin
        raise "failed to enter bitbang mode" if tries >= MAX_TRIES
        @serial_port.puts BITBANG_MODE.chr
        sleep TIMEOUT
        response = @serial_port.read(5)
        tries += 1
      end until response == "BBIO1"
    end

    def set_peripherals(options)
      mask = SET_PERIPHERALS

      mask |= POWER_ON   if options[:power]
      mask |= PULLUPS_ON if options[:pullups]
      mask |= AUX_ON     if options[:aux]
      mask |= CS_ON      if options[:cs]

      tx(mask)
    end

  private
    # Set the BusPirate to the given mode.
    def set_mode(mode, options)
      enter_bitbang_mode

      @protocol =
        case mode
        when :i2c
          Bucaneer::Protocol::I2C.new(self, options)
        when :spi
          Bucaneer::Protocol::SPI.new(self, options)
        else
          raise "unknown mode '#{mode}'"
        end

      set_peripherals(options)

      # Allow things to settle down.
      sleep 0.1
    end
  end
end
