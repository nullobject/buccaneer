require 'serialport'

module Bucaneer
  class BusPirate
    BAUD = 115200

    TIMEOUT   = 0.01
    MAX_TRIES = 40

    BITBANG_MODE = 0x00
    SPI_MODE     = 0x01
    I2C_MODE     = 0x02

    FAILURE = 0x00
    SUCCESS = 0x01

    attr_reader :serial_port, :protocol

  #   private_class_method :new

    def self.connect(mode, options = {})
      dev = options[:dev]
      raise "no device specified" unless dev
      serial_port = SerialPort.new(dev, BAUD)

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
      sleep 0.1
    end

    def tx(byte, expected = SUCCESS)
      @serial_port.putc byte
      sleep TIMEOUT
      response = @serial_port.getc
      raise "failed to send data" unless response == expected
      response
    end

  private
    # Set the BusPirate to the given mode.
    def set_mode(mode, options)
      enter_bitbang_mode

      @protocol =
        case mode
        when :i2c
          enter_i2c_mode
          Bucaneer::Protocol::I2C.new(self, options)
        when :spi
          enter_spi_mode
          Bucaneer::Protocol::SPI.new(self, options)
        else
          raise "unknown mode '#{mode}'"
        end
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

    def enter_i2c_mode
      @serial_port.puts I2C_MODE.chr
      sleep TIMEOUT
      response = @serial_port.read(4)
      raise "failed to enter I2C mode" unless response == "I2C1"
    end

    def enter_spi_mode
      @serial_port.puts SPI_MODE.chr
      sleep TIMEOUT
      response = @serial_port.read(4)
      raise "failed to enter SPI mode" unless response == "SPI1"
    end
  end
end
