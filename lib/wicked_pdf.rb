# wkhtml2pdf Ruby interface
# http://wkhtmltopdf.org/

require 'logger'
require 'digest/md5'
require 'rbconfig'
require 'open3'

require 'active_support/core_ext/object/blank'

require 'wicked_pdf/version'
require 'wicked_pdf/tempfile'
require 'wicked_pdf/binary'
require 'wicked_pdf/option_parser'
require 'wicked_pdf/progress'
require 'wicked_pdf/document'
require 'wicked_pdf/railtie' if defined?(Rails.env)
require 'wicked_pdf/middleware'

module WickedPdf
  class << self
    attr_accessor :config
  end

  def self.new(wkhtmltopdf_binary_path = nil)
    WickedPdf::Document.new(wkhtmltopdf_binary_path)
  end
end
