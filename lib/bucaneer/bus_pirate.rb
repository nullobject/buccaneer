require "io/wait"
require "serialport"

module Bucaneer
  class BusPirate
    DEFAULT_BAUD    = 115200

    TIMEOUT         = 0.01
    MAX_TRIES       = 40

    BITBANG_MODE    = 0x00
    RESET           = 0x0f

    SET_PERIPHERALS = 0x40
    POWER_ON        = 0x08
    PULLUPS_ON      = 0x04
    AUX_ON          = 0x02
    CS_ON           = 0x01

    FAILURE         = 0x00
    SUCCESS         = 0x01

    attr_reader :serial_port, :protocol

    def self.connect(options = {})
      dev  = options.delete(:dev)
      mode = options.delete(:mode)
      baud = options.delete(:baud) || DEFAULT_BAUD

      raise "no device specified" unless dev
      raise "no mode specified"   unless mode

      serial_port = SerialPort.new(dev, baud)
      bus_pirate  = Bucaneer::BusPirate.new(serial_port, mode, options)

      if block_given?
        begin
          yield bus_pirate.protocol
        ensure
          begin
            bus_pirate.close
          rescue
            # Do nothing.
          end
        end
      end

      bus_pirate
    end

    def initialize(serial_port, mode, options)
      @serial_port = serial_port
      set_mode(mode.to_sym, options)
    end

    def close
      @serial_port.write BITBANG_MODE.chr
      sleep 0.1
      @serial_port.write RESET.chr
      sleep 0.1
      @serial_port.close
    end

    def tx(byte)
      @serial_port.putc byte
      sleep TIMEOUT
      @serial_port.readbyte
    end

    def flush_read_buffer
      n = @serial_port.nread
      @serial_port.read(n)
    end

    def reset
      puts "resetting..."
      @serial_port.write "\n\n\n\n\n\n\n\n\n\n#\n"
      r, w, e = select([@serial_port], nil, nil, 0.1)
      flush_read_buffer
      puts "ok"
    end

    def enter_bitbang_mode
      puts "entering bitbang mode..."
      tries = 0
      while true
        raise "failed to enter bitbang mode" if tries >= MAX_TRIES
        @serial_port.write BITBANG_MODE.chr
        r, w, e = select([@serial_port], nil, nil, TIMEOUT)
        break if r
        tries += 1
      end
      response = @serial_port.read(5)
      flush_read_buffer
      unless response == "BBIO1"
        raise "failed to enter bitbang mode"
      end
      puts "ok"
    end

    def set_peripherals(options)
      puts "setting peripherals..."
      mask = SET_PERIPHERALS

      mask |= POWER_ON   if options[:power]
      mask |= PULLUPS_ON if options[:pullups]
      mask |= AUX_ON     if options[:aux]
      mask |= CS_ON      if options[:cs]

      unless tx(mask) == SUCCESS
        raise "failed to set peripherals"
      end

      puts "ok"
    end

  private

    # Set the BusPirate to the given mode.
    def set_mode(mode, options)
      reset
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

      # Allow things to settle down.
      sleep 1
    end
  end
end
