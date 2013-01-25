require "spec_helper"

describe Bucaneer::Protocol::SPI do
  let(:controller) { double(tx: nil, serial_port: StringIO.new("SSPI1")) }

  let(:spi) { Bucaneer::Protocol::SPI.new(controller) }

  subject { controller }
end
