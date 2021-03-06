require "spec_helper"

describe Buccaneer::BusPirate do
  let(:bus_pirate)  { double }
  let(:serial_port) { StringIO.new }

  let(:options) do
    {
      dev:  '/dev/null',
      mode: :i2c,
      foo:  :bar
    }
  end

  describe ".connect" do
    before do
      SerialPort.stub(:new) { serial_port }
      Buccaneer::BusPirate.stub(:new) { bus_pirate }
    end

    it "should open a serial port to the given device" do
      SerialPort.should_receive(:new).with('/dev/null', 115200)
      Buccaneer::BusPirate.connect(options)
    end

    it "should pass the arguments to the bus pirate" do
      Buccaneer::BusPirate.should_receive(:new).with(serial_port, :i2c, foo: :bar)
      Buccaneer::BusPirate.connect(options)
    end
  end
end
