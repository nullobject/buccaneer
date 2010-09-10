require 'bucaneer'

PIRATE_DEV = '/dev/tty.usbserial-A7004HZe'

BLINKM_ADDRESS     = 0x09
BLINKM_STOP_SCRIPT = 0x6f
BLINKM_SET_COLOR   = 0x6e
BLINKM_FADE_COLOR  = 0x63
BLINKM_PLAY_SCRIPT = 0x70

Bucaneer::BusPirate.connect(PIRATE_DEV, :i2c) do |i2c|
  def blinkm_stop_script(i2c)
    puts "Stopping BlinkM script"
    i2c.tx(BLINKM_ADDRESS, BLINKM_STOP_SCRIPT)
  end

  def blinkm_play_script(i2c, n, repeats = 0, offset = 0)
    puts "Playing BlinkM script ##{n}"
    i2c.tx(BLINKM_ADDRESS, BLINKM_PLAY_SCRIPT, n, repeats, offset)
  end

  def blinkm_set_color(i2c, r, g, b, fade = false)
    printf("Setting color #%.2x%.2x%.2x\n", r, g, b)
    command = fade ? BLINKM_FADE_COLOR : BLINKM_SET_COLOR
    i2c.tx(BLINKM_ADDRESS, command, r, g, b)
  end

  blinkm_stop_script(i2c)
  blinkm_play_script(i2c, 0x0a)
end
