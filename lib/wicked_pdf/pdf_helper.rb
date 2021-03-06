module WickedPdf
  module PdfHelper
    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base
    end

    def render_to_string(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        WickedPdf::Renderer.new(self).render(options)
      else
        super
      end
    end
  end
end
