require 'spec_helper'

describe Bucaneer::Protocol::I2C do
  let(:controller) do
    Object.new.tap do |o|
      stub(o).tx
      stub(o).serial_port { StringIO.new("I2C1") }
    end
  end

  let(:i2c) { Bucaneer::Protocol::I2C.new(controller) }

  describe "#initialize" do
    before { i2c }

    it "should set the I2C speed" do
      controller.should have_received.tx(0x62)
    end
  end

  describe "#tx" do
    before { i2c.tx(0x01, 0xf2, 0xf3) }

    subject { controller }

    it { should have_received.tx(0x02)    } # start
    it { should have_received.tx(0x12)    } # bulk write
    it { should have_received.tx(0x02, 0) } # address
    it { should have_received.tx(0xf2, 0) } # byte
    it { should have_received.tx(0xf3, 0) } # byte
    it { should have_received.tx(0x03)    } # stop
  end
end
