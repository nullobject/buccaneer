require "spec_helper"

describe Buccaneer::Protocol::SPI do
  let(:controller) { double(tx: nil, serial_port: StringIO.new("SSPI1")) }

  let(:spi) { Buccaneer::Protocol::SPI.new(controller) }

  subject { controller }
end
