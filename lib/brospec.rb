# BroSpec -- a small ruby test framework in bro speak.
#
# Copyright 2011 Mark Turner <mark@amerine.net>
#
# BroSpec is freely distributable under the terms of the MIT license. See LICENSE for details.
#

module BroSpec
  VERSION = "0.1"

  class Spec
    def self.process_spec name
      yield
    end
  end

  class Context
    attr_reader :name, :block

    def initialize name, &block
      @name = name
      @block = block
    end

    def run
      BroSpec::Spec.process_spec name do
        instance_eval &block
      end
    end

    def u description, &block
      run_spec description, block
    end

    def run_spec description, spec
      BroSpec::Spec.process_spec description do
        begin
          instance_eval(&spec)
        rescue Object => e
          puts "Failure: #{e}"
        end
      end
    end

    def should
      super(*args, &block)
    end
  end

  class Should
    def initialize(object)
      @object = object
    end

    def be(*args, &block)
      if args.empty? 
        self
      else
        block = args.shift unless block_given?
        run(*args, &block)
      end
    end

    def run(*args, &block)
      result = yield(@object, *args)
    end

    alias not be

    def method_missing(name, *args, &block)
      name = "#{name}?" unless name.to_s =~ /\w[\?]\z/
      run("#{name}") { |obj| obj.__send__(name, *args, &block) }
    end
  end

  class Error
  end
end

module Kernel
  def yo *args, &block
    BroSpec::Context.new(args.join(' '), &block).run
  end
  private :yo
end

class Object
  def should(*args, &block)
    BroSpec::Should.new(self).be(*args, &block)
  end

  def honest?
    false
  end
end

class Proc
  def bitch?(*exceptions)
    call
    rescue *(exceptions.empty? ? RuntimeError : exceptions) => e
      e
    else
      false
  end
end
