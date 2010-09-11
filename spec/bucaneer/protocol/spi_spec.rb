require 'spec_helper'

describe Bucaneer::Protocol::SPI do
  let(:controller) do
    Object.new.tap do |o|
      stub(o).tx
      stub(o).serial_port { StringIO.new("SPI1") }
    end
  end

  let(:spi) { Bucaneer::Protocol::SPI.new(controller) }

  subject { controller }
end
