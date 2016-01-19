#!/usr/bin/env ruby
require 'thread'
require 'yaml'

if ARGV.size != 2
  puts "You must run this script with two arguments: Concurrency, and the Total Number of Runs to Perform"
  exit 1
end

CONCURRENCY      = ARGV[0].to_i

@threads         = []
@classifications = []
@nodes_mutex     = Mutex.new
@total_runs      = ARGV[1].to_i

def get_a_node
  number = 1 + Random.rand(300)
  "user#{number}-rc-agent-27.us-west-2.compute.internal"
end

def perform_runs(total_runs)
  while @total_runs > 0
    CONCURRENCY.times.each do
      @threads << Thread.new(@classifications) do |i|
        output = YAML.load(%x{./external_node.rb #{get_a_node}})
      end
      sleep 1
    end
    @total_runs = @total_runs - CONCURRENCY
  end
end

perform_runs(@total_runs)

File.open('last_run.yaml', 'w') do |f|
  f.write @classifications.to_yaml
end
