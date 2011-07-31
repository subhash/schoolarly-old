desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts 'running cron'  
  @shares = Share.latest
  @shares.each {|k,v| ShareMailer.deliver_summary_notification(k,v)}
end

namespace :routes do 
  desc 'Access helper methods in rake tasks' 
  task :test => :environment do 
    include ActionController::UrlWriter 
    puts ActionMailer::Base.default_url_options[:host].inspect 
    puts ENV['MY_HOST'].inspect
  end
end