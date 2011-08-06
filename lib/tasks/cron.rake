desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts 'running cron'  
  ActionMailer::Base.logger = Logger.new(STDOUT)
  @shares = Share.latest
  puts 'shares - '+@shares.inspect
  @shares.each  do |user, shares|
    shares = shares.select {|s| ShareMailer.notify?(s) && s.published?}
    ShareMailer.deliver_summary_notification(user, shares) unless shares.empty?
  end
end