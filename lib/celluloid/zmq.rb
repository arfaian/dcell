require 'ffi-rzmq'

require 'celluloid'
require 'celluloid/zmq/mailbox'
require 'celluloid/zmq/reactor'

module Celluloid
  # Actors which run alongside 0MQ operations
  # This is a temporary hack (hopefully) until ffi-rzmq exposes IO objects for
  # 0MQ sockets that can be used with Celluloid::IO
  module ZMQ
    def self.included(klass)
      klass.send :include, ::Celluloid
      klass.use_mailbox Celluloid::ZMQ::Mailbox
    end

    # Wait for the given IO object to become readable
    def wait_readable(socket)
      # Law of demeter be damned!
      current_actor.mailbox.reactor.wait_readable(socket)
    end

    # Wait for the given IO object to become writeable
    def wait_writeable(socket)
      current_actor.mailbox.reactor.wait_writeable(socket)
    end
  end
end