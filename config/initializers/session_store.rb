# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_schoolarly_session',
  :secret      => '1fada4b0864968804e686ce42124f5c050729f90f66a183582a7fd15eb3d219744080e0835bf0ec23a70b6ec3948c9a003a1f37a99b14e565deebc8ef1b33f5a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
