require 'test_helper'
require 'hyperclient'

describe Hyperclient do
  describe 'new' do
    it 'creates a new EntryPoint with the url' do
      Hyperclient::EntryPoint.expects(:new).with('http://api.example.org')

      Hyperclient.new('http://api.example.org')
    end
  end
end
