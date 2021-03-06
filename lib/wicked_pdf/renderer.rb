module WickedPdf
  class Renderer
    attr_reader :controller

    def initialize(controller)
      @controller = controller
      @hf_tempfiles = []
    end

    def render(options)
      options[:basic_auth] = set_basic_auth(options)
      make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
    end

    def render_to_string(options)
      options[:basic_auth] = set_basic_auth(options)
      options.delete :pdf
      make_pdf((WickedPdf.config || {}).merge(options))
    end

    private

    def set_basic_auth(options = {})
      options[:basic_auth] ||= WickedPdf.config.fetch(:basic_auth, false)
      return unless options[:basic_auth] && controller.request.env['HTTP_AUTHORIZATION']
      controller.request.env['HTTP_AUTHORIZATION'].split(' ').last
    end

    def make_pdf(options = {})
      html_string = controller.render_to_string(render_options(options))
      options = prerender_header_and_footer(options)

      document = WickedPdf::Document.new(command(options[:wkhtmltopdf]))
      document.pdf_from_string(html_string, options)
    ensure
      clean_temp_files
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:layout] ||= false
      options[:template] ||= File.join(controller.controller_path, controller.action_name)
      options[:disposition] ||= 'inline'
      if options[:show_as_html]
        controller.render(render_options(options).merge(:content_type => 'text/html'))
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], 'wb') { |file| file << pdf_content } if options[:save_to_file]
        controller.send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    # Given an options hash, prerenders content for the header and footer sections
    # to temp files and return a new options hash including the URLs to these files.
    def prerender_header_and_footer(options)
      [:header, :footer].each do |hf|
        next unless options[hf] && options[hf][:html] && options[hf][:html][:template]

        options[hf][:html][:layout] ||= options[:layout]
        render_opts = render_options(options[hf][:html])
        path = render_to_tempfile("wicked_#{hf}_pdf.html", render_opts)
        options[hf][:html][:url] = "file:///#{path}"
      end
      options
    end

    def render_options(options)
      options.slice(:template, :prefixes, :layout, :formats, :handlers, :assigns, :inline, :locals, :file)
    end

    def render_to_tempfile(filename, options)
      tf = WickedPdf::Tempfile.new(filename)
      @hf_tempfiles.push(tf)
      tf.write controller.render_to_string(options)
      tf.flush
      tf.path
    end

    def command(binary_path)
      if binary_path
        WickedPdf::Command.new binary: WickedPdf::Binary.new(binary_path)
      else
        WickedPdf::Command.new
      end
    end

    def clean_temp_files
      @hf_tempfiles.each(&:close!)
    end
  end
end
