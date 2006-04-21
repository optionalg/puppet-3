require 'ipaddr'
require 'puppet/server/authstore'

module Puppet
class Server
    # Define a set of rights and who has access to them.
    class Rights
        # We basically just proxy directly to our rights.  Each Right stores
        # its own auth abilities.
        [:allow, :allowed?, :deny].each do |method|
            define_method(method) do |name, *args|
                if obj = right(name)
                    obj.send(method, *args)
                else
                    raise ArgumentError, "Unknown right '%s'" % name
                end
            end
        end

        def initialize
            @rights = {}
        end

        # Define a new right to which access can be provided.
        def newright(name)
            name = name.intern if name.is_a? String
            shortname = Right.shortname(name)
            if @rights.include? shortname
                raise ArgumentError, "Right '%s' is already defined" % name
            else
                @rights[shortname] = Right.new(name, shortname)
            end
        end

        private

        # Retrieve a right by name.
        def right(name)
            @rights[Right.shortname(name)]
        end

        # A right.
        class Right < AuthStore
            attr_accessor :name, :shortname

            def self.shortname(name)
                name.to_s[0..0]
            end

            def initialize(name, shortname = nil)
                @name = name
                @shortname = shortname
                unless @shortname
                    @shortname = Right.shortname(name)
                end
                super()
            end
        end
    end
end
end
#
# $Id$