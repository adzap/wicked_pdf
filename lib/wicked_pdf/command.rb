module WickedPdf
  class Command
    attr_reader :binary, :option_parser

    def initialize(binary: Binary.new, option_parser: nil)
      @binary = binary
      @option_parser = option_parser || OptionParser.new(@binary.version)
    end

    def execute(options, *args)
      command = [binary.path]
      command += option_parser.parse(options)
      command += args

      print_command(command.inspect) if in_development_mode?

      if track_progress?(options)
        Progress.new(options[:progress]).execute(command)
      else
        begin
          err = Open3.popen3(*command) do |_stdin, _stdout, stderr|
            stderr.read
          end
        rescue StandardError => e
          raise "Failed to execute:\n#{command}\nError: #{e}"
        end

        raise "Error generating PDF\n Command Error: #{err}" if options[:raise_on_all_errors] && !err.empty?
        err
      end
    end

    private

    def in_development_mode?
      defined?(Rails.env) && Rails.env.development?
    end

    def print_command(cmd)
      # TODO: if no Rails what then?
      Rails.logger.debug '[wicked_pdf]: ' + cmd
    end

    def track_progress?(options)
      options[:progress] && !on_windows?
    end

    def on_windows?
      RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
    end
  end
end
