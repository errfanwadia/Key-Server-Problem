require 'sinatra'
require './models'
require './commons'
require 'uuid'

# debug = true

get '/gen-key' do

  uuid = UUID.new
  server_key = uuid.generate
  ServerKey.create(
               :key_id => server_key,
               :state => 0,
               :ts => Time.now
  )

  puts "Key Generated: #{server_key}"
  db_info()

  content_type :json
  { :message => "Key generated successfully"}.to_json
end

get '/get-key' do

  server_key = ServerKey.first(:state => 0)

  if server_key == nil
    error 404

  else
    puts "Served key: #{server_key.key_id}"
    server_key.update(
        :state => 2,
        :ts => Time.now
    )
  end

  db_info()

  content_type :json
  { :key => server_key.key_id, :message => "Key retrieved successfully"}.to_json
end

get '/unblock-key/:key' do |key|

  server_key = ServerKey.first(
      :key_id => key,
      :state => 2
  )

  if server_key == nil
    error 404

  else
    puts "Unblocked key: #{server_key.key_id}"
    server_key.update(:state => 0, :ts => Time.now)
  end

  db_info()

  content_type :json
  { :message => "Key unblocked successfully"}.to_json
end

get '/remove-key/:key' do |key|

  server_key = ServerKey.first(
      :key_id => key,
      :state.not => 1
  )

  if server_key == nil
    puts "Removed already or not exist"
    error 404

  else
    puts "Key removed: #{server_key.key_id}"
    server_key.update(:state => 1, :ts => Time.now)
  end

  db_info()

  content_type :json
  { :message => "Key removed successfully"}.to_json
end

get '/ping/:key' do |key|

  server_key = ServerKey.first(
      :key_id => key,
      :state => 0
  )

  if server_key == nil
    error 404

  else
    server_key.update(:ts => Time.now)
  end

  db_info()

  content_type :json
  { :message => "Keep alive request successful"}.to_json
end
