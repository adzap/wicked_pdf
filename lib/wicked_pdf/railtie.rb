require 'wicked_pdf/pdf_helper'
require 'wicked_pdf/renderer'
require 'wicked_pdf/asset_helper'

class WickedPdf
  class Railtie < Rails::Railtie
    initializer 'wicked_pdf.register' do |_app|
      ActionController::Base.send :prepend, PdfHelper
      ActionController::Renderers.add :pdf do |template, options|
        WickedPdf::Renderer.new(self).render(options.merge(:pdf => template))
      end
      ActionView::Base.send :include, WickedPdf::AssetHelper
    end
  end
end

if Mime::Type.lookup_by_extension(:pdf).nil?
  Mime::Type.register('application/pdf', :pdf)
end
