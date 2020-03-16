# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'combustion'

Combustion.path = 'test/dummy'
Combustion.initialize!(:all) do
  if Rails::VERSION::MAJOR < 6.0 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer) # Rails 5.2
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

require 'rails/test_help'
require 'mocha'
require 'mocha/mini_test'

require 'wicked_pdf'

WickedPdf.config = { :exe_path => ENV['WKHTMLTOPDF_BIN'] || '/usr/local/bin/wkhtmltopdf' }

Rails.backtrace_cleaner.remove_silencers!

if (assets_dir = Rails.root.join('app/assets')) && File.directory?(assets_dir)
  # Copy CSS file
  destination = assets_dir.join('stylesheets/wicked.css')
  source = File.read('test/fixtures/wicked.css')
  File.open(destination, 'w') { |f| f.write(source) }

  # Copy JS file
  destination = assets_dir.join('javascripts/wicked.js')
  source = File.read('test/fixtures/wicked.js')
  File.open(destination, 'w') { |f| f.write(source) }
end
