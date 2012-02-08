require 'spec_helper'

describe Mutant::Random do
  describe '.string' do
    it 'returns a random string' do
      Mutant::Random.string.should be_a(String)
    end
  end

  describe '.symbol' do
    it 'returns a random symbol' do
      Mutant::Random.symbol.should be_a(Symbol)
    end
  end

  describe '.range' do
    it 'returns a random range' do
      Mutant::Random.range.should be_a(Range)
    end
  end
end