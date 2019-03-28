class WickedPdf
  module WickedPdfHelper
    def self.root_path
      String === Rails.root ? Pathname.new(Rails.root) : Rails.root
    end

    def self.add_extension(filename, extension)
      filename.to_s.split('.').include?(extension) ? filename : "#{filename}.#{extension}"
    end

    def wicked_pdf_stylesheet_link_tag(*sources)
      css_dir = WickedPdfHelper.root_path.join('public', 'stylesheets')
      css_text = sources.collect do |source|
        source = WickedPdfHelper.add_extension(source, 'css')
        "<style type='text/css'>#{File.read(css_dir.join(source))}</style>"
      end.join("\n")
      css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
    end
  end
end
