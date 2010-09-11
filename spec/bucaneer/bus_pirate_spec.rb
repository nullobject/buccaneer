require 'spec_helper'

describe Bucaneer::BusPirate do
  let(:bus_pirate)  { Object.new }
  let(:serial_port) { StringIO.new }

  let(:options) do
    {
      :dev  => '/dev/null',
      :mode => :i2c,
      :foo  => :bar
    }
  end

  describe ".connect" do
    before do
      stub(SerialPort).new { serial_port }
      stub(Bucaneer::BusPirate).new { bus_pirate }
      Bucaneer::BusPirate.connect(options)
    end

    it "should open a serial port to the given device" do
      SerialPort.should have_received.new('/dev/null', 115200)
    end

    it "should pass the arguments to the bus pirate" do
      Bucaneer::BusPirate.should have_received.new(serial_port, :i2c, {:foo => :bar})
    end
  end
end
