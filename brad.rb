require 'rubygems'
require 'bundler/setup'

require 'serialport'

TIMEOUT = 0.01
MAX_TRIES = 40

BITBANG_MODE = 0x00
SPI_MODE     = 0x01
I2C_MODE     = 0x02

I2C_SPEED_100 = 0x62
I2C_POWER_ON  = 0x48
I2C_PULLUP_ON = 0x44
I2C_START     = 0x02
I2C_STOP      = 0x03
I2C_WRITE     = 0x10

BLINKM_ADDRESS     = 0x09
BLINKM_STOP_SCRIPT = 0x6f
BLINKM_SET_COLOR   = 0x6e
BLINKM_FADE_COLOR  = 0x63

FAILURE = 0x00
SUCCESS = 0x01

ACK  = 0x00
NACK = 0x01

def pirate_send(io, byte, expected = SUCCESS)
  io.putc byte
  sleep TIMEOUT
  response = io.getc
  raise "failed to send data" unless response == expected
  response
end

def pirate_bitbang_mode(io)
  tries = 0
  begin
    raise "failed to enter bitbang mode" if tries >= MAX_TRIES
    io.puts BITBANG_MODE.chr
    sleep TIMEOUT
    response = io.read(5)
    tries += 1
  end until response == "BBIO1"
end

def pirate_i2c_mode(io)
  io.puts I2C_MODE.chr
  sleep TIMEOUT
  response = io.read(4)
  raise "failed to enter I2C mode" unless response == "I2C1"
end

def i2c_init(io)
  pirate_send(io, I2C_POWER_ON | I2C_PULLUP_ON)
  pirate_send(io, I2C_SPEED_100)
  sleep 0.1
end

def i2c_send(io, address, *bytes)
  pirate_send(io, I2C_START)
  pirate_send(io, I2C_WRITE | bytes.length)
  pirate_send(io, address << 1, ACK)
  bytes.each do |byte|
    pirate_send(io, byte, ACK)
  end
  pirate_send(io, I2C_STOP)
end

def blinkm_stop_script(io)
  puts "Stopping BlinkM script"
  i2c_send(io, BLINKM_ADDRESS, BLINKM_STOP_SCRIPT)
end

def blinkm_set_color(io, r, g, b, fade = false)
  printf("Setting color #%.2x%.2x%.2x\n", r, g, b)
  command = fade ? BLINKM_FADE_COLOR : BLINKM_SET_COLOR
  i2c_send(io, BLINKM_ADDRESS, command, r, g, b)
end

SerialPort.open('/dev/tty.usbserial-A7004HZe', 115200) do |s|
  pirate_bitbang_mode(s)
  pirate_i2c_mode(s)

  i2c_init(s)

  blinkm_stop_script(s)

  while true do
    blinkm_set_color(s, rand(255), rand(255), rand(255), false)
    sleep 0.5
  end
end
