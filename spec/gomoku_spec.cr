require "./spec_helper"

describe Gomoku do
  # TODO: Write tests

  it "works" do
    true.should eq(true)
  end

  it "build" do
    10.times do
      Gomoku::Builder.new(10).make.print
      sleep 1
    end
  end
end
