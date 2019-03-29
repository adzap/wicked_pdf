module WickedPdf
  class Progress
    require 'pty' # no support for windows
    require 'English'

    def initialize(callback = nil)
      @callback = callback
    end

    def execute(command)
      output = []
      begin
        PTY.spawn(command.join(' ')) do |stdout, _stdin, pid|
          begin
            stdout.sync
            stdout.each_line("\r") do |line|
              output << line.chomp
              @callback.call(line) if @callback
            end
          rescue Errno::EIO # rubocop:disable Lint/HandleExceptions
            # child process is terminated, this is expected behaviour
          ensure
            ::Process.wait pid
          end
        end
      rescue PTY::ChildExited
        puts 'The child process exited!'
      end
      err = output.join('\n')
      raise "#{command} failed (exitstatus 0). Output was: #{err}" unless $CHILD_STATUS && $CHILD_STATUS.exitstatus.zero?
    end
  end
end
