Sprockets::Redirect [![Build Status](https://secure.travis-ci.org/sikachu/sprockets-redirect.png?branch=master)](http://travis-ci.org/sikachu/sprockets-redirect)
===================

A Rack middleware for [Rails](https://github.com/rails/rails) >= 3.1.0 with asset pipeline and asset digest enabled. This middleware is used to redirect any request to static asset without a digest to the version with digest in its filename by reading the `manifest.yml` file generated after you run `rake assets:precompile`

For example, if a browser is requesting this URL:

    http://example.org/assets/application.js

They will get redirected to:

    http://example.org/assets/application-faa42cf2fd5db7e7290baa07109bc82b.js

This gem is designed to run on your staging or production environment, where you already precompile all your assets, turn on your asset digest, and turn of asset compilation. This is useful if you're having a static page or E-Mail which refers to static assets in the asset pipeline, which might be impossible and impractical for you to use an URL with a digest in it.


Requirements
------------

* Application running on [Ruby on Rails](http://github.com/rails/rails) version >= 3.1.0.
* Enable asset digest by setting `config.assets.digest = true` in your production or staging environment configuration file.
* Running `rake assets:precompile` to precompile your static assets after deploy to your production or staging server.


Installation
------------

Insert this line into your Gemfile:

    group :production, :staging do
      gem 'sprockets-redirect'
    end


Usage
-----

This middleware will be enabled by default if you set `config.assets.compile = false` and `config.assets.digest = true` in your configuration file. It will automatically retrieve your asset prefix and the list of your digests automatically from Rails.

You could also config this middle ware at a class level, or at middleware initialization.


### Configuration at class level:

You can set these configurations at your initializer file:

#### Sprockets::Redirect.enabled = (true|false)

Set this to `false` to override the auto detection and turn off this middleware. Default value is `true`.

#### Sprockets::Redirect.manifest = [path to your manifest.yml]

Set this to another YAML file which override Rails' default digests manifest. Default value is `nil`.

#### Sprockets::Redirect.redirect_status = (301|302)

Set this to override the redirection status. By default, this middleware will use `302` status to prevent any proxy server to cache your redirection, as the target might be changed later.


### Configuration at class initialization:

These configurations are configured via an option hash:

* `:digests` - Set a hash used for file name lookup. This will be default to Rails' manifest at `Rails.configuration.assets.digests`.
* `:prefix` - Set a path prefix of your assets file. This will be default to `Rails.configuration.assets.prefix` (usually at `/assets`.)
* `:manifest` - Set a path to your own manifest file to use for lookup. This will override both `:digest` hash and `Sprockets::Redirect.manifest` setting.

You can swap out the middleware inserted automatically by the gem by using `config.middleware.swap` in your configuration file:

    config.middleware.swap Sprockets::Redirect, Sprockets::Redirect, :manifest => Rails.root.join('assets', 'manifest.yml').to_s


Contributing
------------

If you found any bug or would like to request a feature, please use Github's [issue tracker](https://github.com/sikachu/sprockets-redirect/issues) to report them. [Pull requests](https://github.com/sikachu/sprockets-redirect/pulls) are always welcomed if you also want to help me fix it. Please make sure to include a test to make sure that I don't break it in the future.


License
-------

This gem is released under MIT license. Please see [LICENSE](https://github.com/sikachu/sprockets-redirect/blob/master/LICENSE) file for more information.


Credit
------

This gem is maintained by [Prem Sichanugrist](http://sikachu.com) ([@sikachu](http://twitter.com/sikachu)) and supported by [thoughtbot, inc](http://thoughtbot.com).
