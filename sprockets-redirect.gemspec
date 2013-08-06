Gem::Specification.new do |s|
  s.name      = 'sprockets-redirect'
  s.version   = '0.1.0'
  s.date      = '2011-09-15'

  s.homepage    = "https://github.com/sikachu/sprockets-redirect"
  s.summary     = "Redirect assets with no digest request to a filename with digest version."
  s.description = <<-EOS
    Rack middleware which will look up your `public/assets/manifest.yml` and
    redirect a request with no digest in the file name to the version with
    digest in the file name.
  EOS

  s.files = [
    'lib/sprockets-redirect.rb',
    'lib/sprockets/redirect.rb',
    'LICENSE',
    'README.md'
  ]

  s.platform = Gem::Platform::RUBY
  s.require_path = "lib"
  s.extra_rdoc_files  = Dir["README*"]

  s.add_dependency 'rack'
  s.add_dependency 'activesupport', '>= 3.1.0'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test'

  s.authors           = ["Prem Sichanugrist"]
  s.email             = "s@sikac.hu"
end
