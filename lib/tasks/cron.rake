desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts 'running cron'  
  @shares = Share.latest
  puts 'shares - '+@shares.inspect
  @shares.each {|k,v| puts ShareMailer.deliver_summary_notification(k,v).inspect}
end