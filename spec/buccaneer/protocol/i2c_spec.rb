require "spec_helper"

describe Buccaneer::Protocol::I2C do
  let(:controller) { double(tx: nil, serial_port: StringIO.new("II2C1"), set_peripherals: nil) }

  describe "#initialize" do
    it "should set the I2C speed" do
      controller.should_receive(:tx).with(0x62)
      Buccaneer::Protocol::I2C.new(controller) { Buccaneer::BusPirate::SUCCESS }
    end
  end

  describe "#tx" do
    let(:i2c) { Buccaneer::Protocol::I2C.new(controller) }

    it "should transmit the given bytes" do
      controller.should_receive(:tx).ordered.with(0x02) { Buccaneer::BusPirate::SUCCESS } # start
      controller.should_receive(:tx).ordered.with(0x12) { Buccaneer::BusPirate::SUCCESS } # bulk write
      controller.should_receive(:tx).ordered.with(0x02) { Buccaneer::Protocol::I2C::ACK } # address
      controller.should_receive(:tx).ordered.with(0xf2) { Buccaneer::Protocol::I2C::ACK } # byte
      controller.should_receive(:tx).ordered.with(0xf3) { Buccaneer::Protocol::I2C::ACK } # byte
      controller.should_receive(:tx).ordered.with(0x03) { Buccaneer::BusPirate::SUCCESS } # stop
      i2c.tx(0x01, 0xf2, 0xf3)
    end
  end
end
