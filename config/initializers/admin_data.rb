AdminData::Config.set = {
  :is_allowed_to_view => lambda {|controller| controller.send('admin?') },
  :is_allowed_to_update => lambda {|controller| controller.send('admin?') }
}
