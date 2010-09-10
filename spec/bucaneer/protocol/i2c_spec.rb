require 'spec_helper'

describe BP::I2C do
  let(:controller) { stub(o = Object.new).tx; o }

  describe "#initialize" do
    it "should enable the power and pullups" do
      BP::I2C.new(controller)
      controller.should have_received.tx(0x4c) # power/pullups on
    end
  end

  describe "#tx" do
    before do
      i2c = BP::I2C.new(controller)
      i2c.tx(0x01, 0xf2, 0xf3)
    end

    subject { controller }

    it { should have_received.tx(0x02)    } # start
    it { should have_received.tx(0x12)    } # bulk write
    it { should have_received.tx(0x02, 0) } # address
    it { should have_received.tx(0xf2, 0) } # byte
    it { should have_received.tx(0xf3, 0) } # byte
    it { should have_received.tx(0x03)    } # stop
  end
end
