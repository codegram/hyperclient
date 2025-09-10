require 'minitest'
require 'webmock'
WebMock.enable!
require 'hyperclient'

Minitest::Spec.new nil if defined?(Minitest::Spec)
Spinach.config[:failure_exceptions] << Minitest::Assertion

class Spinach::FeatureSteps
  include Minitest::Assertions

  attr_accessor :assertions

  def initialize(*args)
    super
    self.assertions = 0
  end
end
