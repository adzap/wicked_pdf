require 'test_helper'

class WickedPdfDocumentTest < ActiveSupport::TestCase
  HTML_DOCUMENT = '<html><body>Hello World</body></html>'.freeze

  def setup
    @document = WickedPdf::Document.new
  end

  test 'should generate PDF from html document' do
    pdf = @document.pdf_from_string HTML_DOCUMENT
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should generate PDF from html document with long lines' do
    document_with_long_line_file = File.new('test/fixtures/document_with_long_line.html', 'r')
    pdf = @document.pdf_from_string(document_with_long_line_file.read)
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should generate PDF from html existing HTML file without converting it to string' do
    filepath = File.join(Dir.pwd, 'test/fixtures/document_with_long_line.html')
    pdf = @document.pdf_from_html_file(filepath)
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should output progress when creating pdfs on compatible hosts' do
    document = WickedPdf::Document.new
    output = []
    options = { :progress => proc { |o| output << o } }
    document.pdf_from_string HTML_DOCUMENT, options
    if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
      assert_empty output
    else
      assert(output.collect { |l| !l.match(/Loading/).nil? }.include?(true)) # should output something like "Loading pages (1/5)"
    end
  end

  test 'should raise exception when pdf is empty' do
    begin
      tmp = Tempfile.new('wkhtmltopdf')
      fp = tmp.path
      File.chmod 0o777, fp
      command = WickedPdf::Command.new(binary: WickedPdf::Binary.new(fp))
      document = WickedPdf::Document.new command

      assert_raise RuntimeError do
        document.pdf_from_string HTML_DOCUMENT
      end
    ensure
      tmp.delete
    end
  end
end
