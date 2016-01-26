require 'sprockets/redirect'
require 'test/unit'
require 'fileutils'
require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/string/strip'
require './test/support/bundler_helpers'

class IntegrationTest < Test::Unit::TestCase
  include BundlerHelpers

  def test_build_app_and_add_gem
    create_rails_app
    append_gemfile
    create_test_file
    precompile_assets
    assert_middleware_injection
    assert_asset_redirection
  end

  private

  def app_dir
    File.join(File.dirname(__FILE__), '..', 'tmp', 'test_app')
  end

  def run_command(command)
    output = `#{command} 2>&1`

    assert_equal 0, $?.exitstatus, <<-ERROR.strip_heredoc
      Error executing `#{command}`: exit with status #{$?.exitstatus}
      Output was: #{output}
    ERROR

    output
  end

  def in_app_dir(&block)
    Dir.chdir(app_dir, &block)
  end

  def create_rails_app
    FileUtils.rm_rf(app_dir)
    run_command "bundle exec rails new #{app_dir} --skip-bundle"
  end

  def append_gemfile
    gemfile_path = File.join(app_dir, 'Gemfile')

    File.open(gemfile_path, 'a') do |f|
      f.puts
      f.puts 'gem "sprockets-redirect", :path => "../../"'
      f.puts 'gem "test-unit"'

      begin
        require "sprockets/rails/version"
        f.puts %(gem "sprockets-rails", "#{Sprockets::Rails::VERSION}")
      rescue LoadError
        # Unable to determine Sprockets::Rails version, so we just ignore it.
      end
    end

    reset_bundler_environment_variables
    in_app_dir { run_command "bundle install && rake db:migrate" }
  end

  def create_test_file
    in_app_dir do
      File.open('config/application.rb', 'a') do |file|
        file.puts <<-disable_assets_compilation.strip_heredoc
          Rails.configuration.assets.digest = true
          Rails.configuration.assets.compile = false
        disable_assets_compilation
      end

      File.open('test/integration/sprockets_redirect_test.rb', 'w') do |file|
        file.puts <<-sprockets_redirect_test.strip_heredoc
          require 'test_helper'

          class SprocketsRedirectTest < ActionDispatch::IntegrationTest
            def test_asset_redirection
              get '/assets/application.js'
              assert_response :redirect
              assert_match %r{/assets/application-.+.js}, response.location
            end
          end
        sprockets_redirect_test
      end
    end
  end

  def precompile_assets
    in_app_dir { run_command "bundle exec rake assets:precompile" }
  end

  def assert_middleware_injection
    output = in_app_dir { run_command 'bundle exec rake middleware' }
    assert_match(/use Sprockets::Redirect/, output)
  end

  def assert_asset_redirection
    in_app_dir do
      run_command "bundle exec ruby -Itest test/integration/sprockets_redirect_test.rb"
    end
  end
end
