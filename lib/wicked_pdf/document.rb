module WickedPdf
  class Document
    def initialize(command = Command.new)
      @command = command
    end

    def pdf_from_html_file(filepath, options = {})
      pdf_from_url("file:///#{filepath}", options)
    end

    def pdf_from_string(string, options = {})
      options = options.dup
      options.merge!(WickedPdf.config) { |_key, option, _config| option }
      string_file = WickedPdf::Tempfile.new('wicked_pdf.html', options[:temp_path])
      string_file.binmode
      string_file.write(string)
      string_file.close

      pdf_from_html_file(string_file.path, options)
    ensure
      string_file.close! if string_file
    end

    def pdf_from_url(url, options = {})
      # merge in global config options
      options.merge!(WickedPdf.config) { |_key, option, _config| option }
      generated_pdf_file = WickedPdf::Tempfile.new('wicked_pdf_generated_file.pdf', options[:temp_path])

      result = @command.execute(options, url, generated_pdf_file.path.to_s)

      if options[:return_file]
        return_file = options.delete(:return_file)
        return generated_pdf_file
      end

      generated_pdf_file.rewind
      generated_pdf_file.binmode
      pdf = generated_pdf_file.read

      raise "PDF could not be generated!\n Command Error: #{result}" if pdf && pdf.rstrip.empty?

      pdf
    ensure
      generated_pdf_file.close! if generated_pdf_file && !return_file
    end
  end
end
