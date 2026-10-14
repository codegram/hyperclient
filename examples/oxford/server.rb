require 'webrick'
require_relative 'app'

app = OxfordExample::App.new
server = WEBrick::HTTPServer.new(BindAddress: '127.0.0.1', Port: Integer(ENV.fetch('PORT', '9292')))
server.mount_proc('/') do |request, response|
  status, headers, body = app.call('REQUEST_METHOD' => request.request_method, 'PATH_INFO' => request.path)
  response.status = status
  headers.each { |key, value| response[key] = value }
  response.body = body.join
end
%w[INT TERM].each { |signal| trap(signal) { server.shutdown } }
server.start
