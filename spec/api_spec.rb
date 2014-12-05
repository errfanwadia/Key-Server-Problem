require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Key Server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  specify 'Generate key and check the status code' do
    get '/gen-key'
    last_response.should be_ok
  end

  specify 'Get key and check the status code and store the key' do
    get '/get-key'
    last_response.should be_ok

    @gen_key = JSON.parse(last_response.body)
    $key = @gen_key["key"]
  end

  specify 'Get key and check the status code 404' do
    get '/get-key'
    last_response.status.should eql(404)
  end

  specify 'Unblocking the key and checking the status code' do
    get '/unblock-key/'+$key
    last_response.should be_ok
  end

  specify 'Unblocking the key and checking the response body' do

    get '/gen-key'
    get '/get-key'
    @gen_key = JSON.parse(last_response.body)
    $key = @gen_key["key"]
    get '/unblock-key/'+$key
    last_response.should be_ok
    last_response.body.should eql("{\"message\":\"Key unblocked successfully\"}")
  end

  specify 'Unblocking the key and checking the status code for 404' do
    get '/unblock-key/'+$key
    last_response.status.should eql(404)
  end

  specify 'Keep alive the key and checking the response message' do
    get '/ping/'+$key
    last_response.body.should eql("{\"message\":\"Keep alive request successful\"}")
  end

  specify 'Keep alive the key and checking the response code' do
    get '/ping/'+$key
    last_response.status.should eql(200)
  end

  specify 'Keep alive the key and checking the status code for 404' do
    get '/ping/'+'kjbasdkasbdkasdk'
    last_response.status.should eql(404)
  end

  specify 'Remove the key and checking the response code' do
    get '/remove-key/'+$key
    last_response.status.should eql(200)
  end

  specify 'Remove the key and check the response msg' do

    get '/gen-key'
    get '/get-key'
    @gen_key = JSON.parse(last_response.body)

    $key = @gen_key["key"]
    puts "Key removed: "+$key

    get '/remove-key/'+$key
    last_response.should be_ok
    last_response.body.should eql("{\"message\":\"Key removed successfully\"}")
  end

  specify 'Remove the key and checking the response code' do
    get '/remove-key/'+"asbdkasdkas"
    last_response.status.should eql(404)
  end

  specify 'Generate key and check the content type' do
    get '/gen-key'
    last_response.header['Content-Type'].should include 'application/json'
  end

  specify 'Generate key, get the key and check the content type' do
    get '/gen-key'
    get '/get-key'
    last_response.header['Content-Type'].should include 'application/json'
  end

  specify 'Generate key, get the key, unblock the key and check the content type' do
    get '/gen-key'

    get '/get-key'
    @gen_key = JSON.parse(last_response.body)
    $key = @gen_key["key"]

    get '/unblock-key/'+$key
    last_response.header['Content-Type'].should include 'application/json'
  end

  specify 'Generate key, get the key, unblock the key, ping to keep alive and check the content type' do
    get '/gen-key'

    get '/get-key'
    @gen_key = JSON.parse(last_response.body)
    $key = @gen_key["key"]

    get '/unblock-key/'+$key

    get '/ping/'+$key
    last_response.header['Content-Type'].should include 'application/json'
  end

  specify 'Generate key, get the key, unblock the key, remove the key and check the content type' do
    get '/gen-key'

    get '/get-key'
    @gen_key = JSON.parse(last_response.body)
    $key = @gen_key["key"]

    get '/remove-key/'+$key
    last_response.header['Content-Type'].should include 'application/json'
  end
end
