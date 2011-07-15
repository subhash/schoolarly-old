PDFKit.configure do |config|       
  config.wkhtmltopdf = Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s if RAILS_ENV == 'production'   
  config.wkhtmltopdf = Rails.root.join('bin', 'wkhtmltopdf.exe').to_s if RAILS_ENV == 'development'
end  