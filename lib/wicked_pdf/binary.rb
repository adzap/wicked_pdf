module WickedPdf
  class Binary
    EXE_NAME = 'wkhtmltopdf'.freeze
    DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')

    attr_reader :path, :default_version

    def initialize(binary_path = nil, default_version = DEFAULT_BINARY_VERSION)
      @path = binary_path || find_binary_path
      @default_version = default_version

      raise "Location of #{EXE_NAME} unknown" if @path.empty?
      raise "Bad #{EXE_NAME}'s path: #{@path}" unless File.exist?(@path)
      raise "#{EXE_NAME} is not executable" unless File.executable?(@path)
    end

    def version
      @version ||= retrieve_binary_version
    end

    def parse_version_string(version_info)
      match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
      if match_data && (match_data.length == 2)
        Gem::Version.new(match_data[1])
      else
        default_version
      end
    end

    private

    def retrieve_binary_version
      _stdin, stdout, _stderr = Open3.popen3(@path + ' -V')
      parse_version_string(stdout.gets(nil))
    rescue StandardError
      default_version
    end

    def find_binary_path
      return WickedPdf.config[:exe_path] if WickedPdf.config[:exe_path]

      begin
        detected_path = (defined?(Bundler) ? Bundler.which('wkhtmltopdf') : `which wkhtmltopdf`).chomp
        return detected_path if detected_path.present?
      rescue StandardError
        nil
      end

      possible_locations = (ENV['PATH'].split(':') + %w[/usr/bin /usr/local/bin]).uniq
      possible_locations += %w[~/bin] if ENV.key?('HOME')

      exe_path ||= possible_locations.map { |l| File.expand_path("#{l}/#{EXE_NAME}") }.find { |location| File.exist?(location) }
      exe_path || ''
    end
  end
end
