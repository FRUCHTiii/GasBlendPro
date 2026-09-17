require "minitest/autorun"
require "shellwords"

# Run the real lane with external actions stubbed; no upload or credentials needed.
class BetaLaneHarness
  attr_reader :build_options, :upload_options

  def default_platform(*)
  end

  def desc(*)
  end

  def platform(*)
    yield
  end

  def lane(*)
    yield
  end

  def app_store_connect_api_key(**)
    :api_key
  end

  def build_app(**options)
    @build_options = options
  end

  def upload_to_testflight(**options)
    @upload_options = options
  end

  def run
    path = File.expand_path("../Fastfile", __dir__)
    instance_eval(File.read(path), path)
    self
  end
end

class BetaVersioningTest < Minitest::Test
  def setup
    @saved_environment = ENV.to_h
    ENV["VERSION_NUMBER"] = "1.3.0"
    ENV["BUILD_NUMBER"] = "42.1"
    ENV["PROVISIONING_PROFILE_SPECIFIER"] = "Profile with spaces"
    ENV["APPLE_TEAM_ID"] = "TESTTEAM"
  end

  def teardown
    ENV.replace(@saved_environment)
  end

  def test_ci_versions_reach_archive_and_export_keeps_them
    lane = BetaLaneHarness.new.run
    settings = Shellwords.split(lane.build_options.fetch(:xcargs)).to_h { |arg| arg.split("=", 2) }
    assert_equal "42.1", settings["CURRENT_PROJECT_VERSION"]
    assert_equal "1.3.0", settings["MARKETING_VERSION"]
    assert_equal "Profile with spaces", settings["PROVISIONING_PROFILE_SPECIFIER"]
    assert_equal false, lane.build_options.fetch(:export_options)[:manageAppVersionAndBuildNumber]
    assert_equal :api_key, lane.upload_options[:api_key]
  end

  def test_retry_build_number_reaches_archive
    ENV["BUILD_NUMBER"] = "42.2"
    lane = BetaLaneHarness.new.run
    assert_includes Shellwords.split(lane.build_options.fetch(:xcargs)), "CURRENT_PROJECT_VERSION=42.2"
  end

  def test_missing_or_invalid_versions_fail_before_building
    [nil, "", "42; echo invalid"].each do |value|
      ENV["BUILD_NUMBER"] = value
      lane = BetaLaneHarness.new
      assert_raises(ArgumentError) { lane.run }
      assert_nil lane.build_options
    end
    ENV["BUILD_NUMBER"] = "42.1"
    [nil, "", "v1.3.0"].each do |value|
      ENV["VERSION_NUMBER"] = value
      lane = BetaLaneHarness.new
      assert_raises(ArgumentError) { lane.run }
      assert_nil lane.build_options
    end
  end
end
