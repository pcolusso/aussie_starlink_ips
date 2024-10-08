Gem::Specification.new do |s|
  s.name        = 'aussie_starlink_ips'
  s.version     = '0.0.1'
  s.summary     = 'Loads the Starlink IP list and checks if the specified IP is currently in Australia.'
  #s.description = 'A longer description of your gem'
  s.authors     = ['Paul Colusso']
  # s.email       = 'your.email@example.com'
  s.files = Dir['lib/**/*']
  s.homepage = 'https://github.com/pcolusso/aussie_starlink_ips'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.0.0'
  s.require_paths = ['lib']
  
  s.add_dependency 'netaddr', '~> 2.0' # Parse CIDRs, and general utils.
  s.add_dependency 'csv', '~> 3.3' # Parse CSV, slightly safer than split

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5.1" # Same version as Rails.
  s.add_development_dependency "webmock", "~> 3.14"
  s.add_development_dependency "rbs"
end
