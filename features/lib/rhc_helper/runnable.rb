require 'open4'
require 'timeout'

module RHCHelper
  module Runnable
    include Loggable

    class StringTee < StringIO
      attr_reader :tee
      def initialize(other)
        @tee = other
        super()
      end
      def <<(buf)
        tee << buf
        super
      end
    end

    def run(cmd, arg=nil, input=[])
      logger.info("Running: #{cmd}")

      exit_code = -1
      output = nil

      # Don't let a command run more than 5 minutes
      Timeout::timeout(240) do

        stdout, stderr = (ENV['VERBOSE'] ? [$stdout, $stderr] : [logger, logger]).map{ |t| StringTee.new(t) }
        stdin = input.inject(StringIO.new){ |io, s| io.puts s; io }
        stdin.close_write
        stdin.rewind
        status = Open4.spawn(cmd, 'stdout' => stdout, 'stderr' => stderr, 'stdin' => stdin, 'quiet' => true)
        out, err = [stdout, stderr].map(&:string)

        #pid, stdin, stdout, stderr = Open4::popen4 cmd
        #input.each {|line| stdin.puts line}
        #stdin.close

        # Block until the command finishes
        #ignored, status = Process::waitpid2 pid
        #out = stdout.read.strip
        #err = stderr.read.strip
        stdout.close
        stderr.close
        #logger.debug("Standard Output:\n#{out}")
        #logger.debug("Standard Error:\n#{err}")

        # Allow a caller to pass in a block to process the output
        yield status.exitstatus, out, err, arg if block_given?
        exit_code = status.exitstatus
      end

      if exit_code != 0
        logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}")
      end

      exit_code
    end
  end
end
