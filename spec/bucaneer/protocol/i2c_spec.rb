require "spec_helper"

describe Bucaneer::Protocol::I2C do
  let(:controller) { double(tx: nil, serial_port: StringIO.new("II2C1"), set_peripherals: nil) }

  describe "#initialize" do
    it "should set the I2C speed" do
      controller.should_receive(:tx).with(0x62)
      Bucaneer::Protocol::I2C.new(controller) { Bucaneer::BusPirate::SUCCESS }
    end
  end

  describe "#tx" do
    let(:i2c) { Bucaneer::Protocol::I2C.new(controller) }

    it "should transmit the given bytes" do
      controller.should_receive(:tx).ordered.with(0x02) { Bucaneer::BusPirate::SUCCESS } # start
      controller.should_receive(:tx).ordered.with(0x12) { Bucaneer::BusPirate::SUCCESS } # bulk write
      controller.should_receive(:tx).ordered.with(0x02) { Bucaneer::Protocol::I2C::ACK } # address
      controller.should_receive(:tx).ordered.with(0xf2) { Bucaneer::Protocol::I2C::ACK } # byte
      controller.should_receive(:tx).ordered.with(0xf3) { Bucaneer::Protocol::I2C::ACK } # byte
      controller.should_receive(:tx).ordered.with(0x03) { Bucaneer::BusPirate::SUCCESS } # stop
      i2c.tx(0x01, 0xf2, 0xf3)
    end
  end
end
