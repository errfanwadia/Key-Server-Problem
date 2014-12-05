require './models'
require 'time_difference'

def db_info
  puts "Total no of keys in db: #{ServerKey.count}"
  puts "No of keys for state = active in db: #{ServerKey.count(:state=>0)}"
  puts "No of keys for state = removed in db: #{ServerKey.count(:state=>1)}"
  puts "No of keys for state = blocked in db: #{ServerKey.count(:state=>2)}"
end

t1 = Thread.new {

  while true do
    # print "something happening"

    ServerKey.all.each do |server_key|

      # puts "Key : #{server_key.key_id} and Key state : #{server_key.state}"

      curr_time = Time.now

      if server_key.state == 0

        #Satisfying the condition for E5
        #Check if the timestamp difference is greater than 5 mints then remove the key
        if TimeDifference.between(server_key.ts, curr_time).in_seconds >= 300

          # Key removed
          server_key.update(:state => 1)
          puts "Key removed: #{server_key.key_id} and timestamp: #{server_key.ts}"

          db_info()
        end

      elsif server_key.state == 2

        #Enforcing rule R1 to release the blocked keys within 60 secs if E3 is not called.
        if TimeDifference.between(server_key.ts, curr_time).in_seconds >= 60

          # Activate the key
          puts "Activating the key after being blocked for key: #{server_key.key_id} and timestamp: #{server_key.ts}"
          server_key.update(:state => 0)

          db_info()
        end
      end
    end

    sleep(1)
  end
}
