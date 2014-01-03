module BundlerHelpers
  BUNDLE_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE)
  ORIGINAL_BUNDLE_VARS = Hash[ENV.select{ |key,value| BUNDLE_ENV_VARS.include?(key) }]

  def setup
    super

    ENV['BUNDLE_GEMFILE'] = File.join(Dir.pwd, ENV['BUNDLE_GEMFILE']) unless ENV['BUNDLE_GEMFILE'].start_with?(Dir.pwd)
  end

  def teardown
    super

    ORIGINAL_BUNDLE_VARS.each_pair do |key, value|
      ENV[key] = value
    end
  end

  def reset_bundler_environment_variables
    BUNDLE_ENV_VARS.each do |key|
      ENV[key] = nil
    end
  end
end
