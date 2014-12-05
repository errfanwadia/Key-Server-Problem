require 'rubygems'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite::memory:')

=begin
State:
0 ---- Active
1 ---- Removed
2 ---- Blocked
=end

class ServerKey
  include DataMapper::Resource

  property :key_id, String, :key => true
  property :state, Integer
  property :ts, DateTime
end

DataMapper.finalize

ServerKey.auto_upgrade!