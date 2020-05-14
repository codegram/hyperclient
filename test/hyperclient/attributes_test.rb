require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe Attributes do
    let(:representation) do
      JSON.parse(File.read('test/fixtures/element.json'))
    end

    let(:attributes) do
      Attributes.new(representation)
    end

    it 'does not set _links as an attribute' do
      _(attributes).wont_respond_to :_links
    end

    it 'does not set _embedded as an attribute' do
      _(attributes).wont_respond_to :_embedded
    end

    it 'sets normal attributes' do
      _(attributes).must_respond_to :permitted
      _(attributes.permitted).must_equal true

      _(attributes).must_respond_to :title
      _(attributes.title).must_equal 'Real World ASP.NET MVC3'
    end

    # Underscores should be allowed per http://tools.ietf.org/html/draft-kelly-json-hal#appendix-B.4
    it 'sets _hidden_attribute as an attribute' do
      _(attributes).must_respond_to :_hidden_attribute
      _(attributes._hidden_attribute).must_equal 'useful value'
    end

    it 'is a collection' do
      _(Attributes.ancestors).must_include Collection
    end
  end
end
