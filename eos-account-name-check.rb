# To create an EOS account, you have to choose the 12-character
# name yourself. You must try to be clever or at least not stupid
# because of the enormous cost if you get it wrong.
#
# (Creating an account costs a few bucks. The enormous cost I'm
# talking about is having to admit that you got it wrong.)
#
# This script simply checks every 12-character word in the
# standard Unix dictionary to see if it has already been used
# as an EOS account. It creates a file containing the unused
# ones, so all that's left for you to do is to pick a cool one
# from that list.
#
# This is not a smart implementation, and it takes a long time
# to complete. Feel free to make a smarter one.

# This assumes you installed cleos with docker.
cleos = 'docker exec -i eosio /opt/eosio/bin/cleos --wallet-url http://localhost:8888 -u https://api.eosnewyork.io:443'

File.open('names.txt', 'w') do |outfile|
  File.open('/usr/share/dict/american-english') do |file|
    file.each_line do |line|
      line = line.chomp.downcase
      if line.length == 12 && line =~ /^[\.12345abcdefghijklmnopqrstuvwxyz]+$/
        system "#{cleos} get account #{line} > /dev/null 2>&1"
        outfile.puts line if $?.exitstatus != 0
      end
    end
  end
end
