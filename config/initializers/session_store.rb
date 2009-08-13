# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcms_feeds_session',
  :secret      => '8d0b3eb75c8308e8fc9696c922429edfc5985f753d4e3ef642025286c3f34fa6b83bc263a25665b9db1d9ff566efda721d46bb4380e8ec4e70e961c9a9529219'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
