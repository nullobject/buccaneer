require 'spec_helper'

describe BP::I2C do
  let(:controller) { stub(o = Object.new).tx; o }

  describe "#initialize" do
    it "should enable the power and pullups" do
      BP::I2C.new(controller)
      controller.should have_received.tx(BP::I2C::POWER_ON | BP::I2C::PULLUP_ON)
    end
  end

  describe "#tx" do
    before do
      i2c = BP::I2C.new(controller)
      i2c.tx(0x01, 0xf2, 0xf3)
    end

    subject { controller }

    it { should have_received.tx(BP::I2C::START) }
    it { should have_received.tx(BP::I2C::WRITE | 2) }
    it { should have_received.tx(0x01 << 1, BP::I2C::ACK) }
    it { should have_received.tx(0xf2, BP::I2C::ACK) }
    it { should have_received.tx(0xf3, BP::I2C::ACK) }
    it { should have_received.tx(BP::I2C::STOP) }
  end
end
