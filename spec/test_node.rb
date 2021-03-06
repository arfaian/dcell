#!/usr/bin/env ruby

# The DCell specs start a completely separate Ruby VM running this code
# for complete integration testing using 0MQ over TCP
require 'rubygems'
require 'bundler'
Bundler.setup
require 'coveralls'
Coveralls.wear_merged!
SimpleCov.merge_timeout 3600
SimpleCov.command_name "test:node-#{Process.pid}"

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'dcell'
Dir['./spec/options/*.rb'].map { |f| require f }

class TestActor
  include Celluloid
  attr_reader :value
  attr_accessor :magic
  attr_accessor :mutable

  def initialize
    @value = 42
    @mutable = 0
  end

  def the_answer
    DCell::Global[:the_answer]
  end

  def win(&block)
    yield 10000
    20000
  end

  def crash
    raise "the spec purposely crashed me :("
  end

  def suicide(delay, sig=:TERM)
    sig = sig.to_sym
    SimpleCov.result.format! if sig == :KILL
    # avoid scheduling if no delay
    if delay > 0
      after (delay) {Process.kill sig, Process.pid}
    else
      Process.kill sig, Process.pid
    end
    'Bazinga'
  end
end
TestActor.supervise_as :test_actor

Celluloid.logger = nil
Celluloid.shutdown_timeout = 1

options = {:id => TEST_NODE[:id], :addr => "tcp://#{TEST_NODE[:addr]}:#{TEST_NODE[:port]}"}
options.merge! test_options

DCell.start options
sleep
