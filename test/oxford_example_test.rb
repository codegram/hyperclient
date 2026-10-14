require 'test_helper'
require 'hyperclient'
require 'webmock'
require 'stringio'
require_relative '../examples/oxford/app'

describe OxfordExample::App do
  let(:app) { OxfordExample::App.new }

  before do
    WebMock.enable!
    WebMock.stub_request(:any, %r{\Ahttp://127\.0\.0\.1:9292/}).to_return do |request|
      status, headers, body = app.call('REQUEST_METHOD' => request.method.to_s.upcase,
                                       'PATH_INFO' => request.uri.path)
      { status: status, headers: headers, body: body.join }
    end
  end

  after do
    WebMock.reset!
    WebMock.disable!
  end

  it 'runs the documented client without external requests' do
    output, = capture_io { load File.expand_path('../examples/oxford/client.rb', __dir__) }

    _(output).must_include 'Balliol College: Broad Street OX1 3BJ'
    _(output).must_include 'Followed primary_place: Balliol College'
    _(output).must_include 'Archived depiction URL (not fetched):'
    _(output).must_include 'CURIE: /docs/places'
  end

  it 'supports explicit navigation, hash attributes, and embedded resources' do
    api = Hyperclient.new('http://127.0.0.1:9292/')
    place = api._links.places._embedded.places.first

    _(place[:name]).must_equal 'Balliol College'
    _(place.to_h['id']).must_equal 'oxpoints:23232339'
    _(place._embedded.files.first.type).must_equal 'depiction'
    _(api._links['oxford:places']._embedded.places.first.name).must_equal 'Balliol College'
  end

  it 'serves HAL, rejects writes, and reports missing resources' do
    status, headers, = app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')

    _(status).must_equal 200
    _(headers['content-type']).must_equal 'application/hal+json'
    _(app.call('REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/').first).must_equal 405
    _(app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/missing').first).must_equal 404
    _(app.call('REQUEST_METHOD' => 'HEAD', 'PATH_INFO' => '/').last).must_equal []
  end
end
