require 'spec_helper'
require 'stringio'

describe Bucaneer::BusPirate do
  let(:serial_port)  { StringIO.new("BBIO1") }
  let(:i2c_protocol) { Object.new }

  before do
    any_instance_of(Bucaneer::BusPirate) do |bus_pirate|
      stub(bus_pirate).tx
    end

    stub(SerialPort).new { serial_port }
  end

  describe ".connect" do
    context "I2C mode" do
      context "success" do
        before do
          stub(serial_port).read(5) { "BBIO1" }
          stub(serial_port).read(4) { "I2C1" }
          stub(Bucaneer::Protocol::I2C).new { i2c_protocol }

          Bucaneer::BusPirate.connect(:i2c, :dev => '/foo/bar') do |i2c|
            i2c.should == i2c_protocol
          end
        end

        it "should open a serial port to the given device" do
          SerialPort.should have_received.new('/foo/bar', 115200)
        end

        it "should enter I2C mode" do
          serial_port.string.should =~ /^\000\n\002\n/
        end
      end

      context "fail to enter bitbang mode" do
        it "should raise an error" do
          lambda do
            Bucaneer::BusPirate.connect(:i2c, :dev => '/foo/bar')
          end.should raise_error("failed to enter bitbang mode")
        end
      end

      context "fail to enter I2C mode" do
        it "should raise an error" do
          lambda do
            stub(serial_port).read(5) { "BBIO1" }
            stub(serial_port).read(4) { "XXXX" }
            Bucaneer::BusPirate.connect(:i2c, :dev => '/foo/bar')
          end.should raise_error("failed to enter I2C mode")
        end
      end
    end
  end
end
