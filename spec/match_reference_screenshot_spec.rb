require 'spec_helper.rb'
require 'fileutils'

describe "match_reference_screenshot" do

  Given {
    @opts = { :full => true }
    @driver = mock("Driver")
    @driver.stubs :resize
    @driver.stubs :save_screenshot
    @page = mock("Page")
    @page.stubs(:driver).returns @driver
    @match_argument = nil
  }

  context "helpers" do
    it "use proper paths" do
      expect(reference_screenshot_path).to eq Pathname.new("spec/reference_screenshots/match_reference_screenshot/helpers/use_proper_paths/expected.png")
      expect(test_path).to eq Pathname.new("tmp/spec/reference_screenshots/match_reference_screenshot/helpers/use_proper_paths/test.png")
      expect(difference_path).to eq Pathname.new("tmp/spec/reference_screenshots/match_reference_screenshot/helpers/use_proper_paths/difference.png")
    end
  end


  context "using expect().to" do

    When {
      begin
        expect(@page).to match_reference_screenshot @match_argument
      rescue RSpec::Expectations::ExpectationNotMetError => e
        @error = e
      end
    }

    context "framework" do
      Then { expect(@driver).to have_received(:resize).with(1024, 768) }
      Then { expect(@driver).to have_received(:save_screenshot).with(test_path, @opts) }

      context "selenium" do
        Given {
          @browser = mock("Browser")
          @window = mock("Window")
          @window.stubs(:resize_to)
          manage = mock("Manage")
          manage.stubs(:window).returns @window
          @browser.stubs(:manage => manage)
          @driver.stubs(:browser => @browser)
          @driver.unstub(:resize)
        }

        Then { expect(@window).to have_received(:resize_to).with(1024, 768) }
      end
    end

    context "when files match" do
      Given { use_test_screenshot "A" }
      Given { use_reference_screenshot "A" }

      Then { expect(@error).to be_nil }
    end


    context "when files do not match" do
      Given { use_test_screenshot "A" }
      Given { use_reference_screenshot "B" }

      Then { expect(@error).to_not be_nil }
      Then { expect(@error.message).to include "Test screenshot does not match reference screenshot" }
      Then { expect(@error.message).to match viewer_pattern(test_path, reference_screenshot_path, difference_path) }

      Then { expect(difference_path.read).to eq fixture_screenshot("ABdiff").read }
    end

    context "when difference threshold is set" do
      context "when difference threshold is configured below image difference" do
        Given do
          RSpec::PageRegression.configure do |config|
            config.threshold = 0.01
          end
        end
        Given { use_test_screenshot "A" }
        Given { use_reference_screenshot "B" }

        Then { expect(@error).to_not be_nil }
        Then { expect(@error.message).to include "Test screenshot does not match reference screenshot" }
        Then { expect(@error.message).to match viewer_pattern(test_path, reference_screenshot_path, difference_path) }

        Then { expect(difference_path.read).to eq fixture_screenshot("ABdiff").read }
      end

      context "when difference threshold is configured above image difference" do
        Given do
          RSpec::PageRegression.configure do |config|
            config.threshold = 0.02
          end
        end
        Given { use_test_screenshot "A" }
        Given { use_reference_screenshot "B" }

        Then { expect(@error).to be_nil }
      end

      after :each do
        RSpec::PageRegression.class_variable_set :@@threshold, nil
      end
    end

    context "when test screenshot is missing" do
      Given { use_reference_screenshot "A" }

      Then { expect(@error).to_not be_nil }
      Then { expect(@error.message).to include "Missing test screenshot #{test_path}" }
      Then { expect(@error.message).to match viewer_pattern(reference_screenshot_path) }
      context "with previously-created difference image" do
        Given { preexisting_difference_image }
        Then { expect(difference_path).to_not be_exist }
      end
    end

    context "when reference screenshot is missing" do
      Given { use_test_screenshot "A" }

      Then { expect(@error).to_not be_nil }
      Then { expect(@error.message).to include "Missing reference screenshot #{reference_screenshot_path}" }
      Then { expect(@error.message).to match viewer_pattern(test_path) }
      Then { expect(@error.message).to include "mkdir -p #{reference_screenshot_path.dirname} && cp #{test_path} #{reference_screenshot_path}" }
      context "with previously-created difference image" do
        Given { preexisting_difference_image }
        Then { expect(difference_path).to_not be_exist }
      end
    end

    context "when sizes mismatch" do
      Given { use_test_screenshot "Small" }
      Given { use_reference_screenshot "A" }

      Then { expect(@error).to_not be_nil }
      Then { expect(@error.message).to include "Test screenshot size 256x167 does not match reference screenshot size 512x334" }
      Then { expect(@error.message).to match viewer_pattern(test_path, reference_screenshot_path) }
      context "with previously-created difference image" do
        Given { preexisting_difference_image }
        Then { expect(difference_path).to_not be_exist }
      end
    end

    context "with match argument" do
      Given { @match_argument = "/this/is/a/test.png" }
      Then { expect(@error.message).to include "Missing reference screenshot /this/is/a/test.png" }
      context "with previously-created difference image" do
        Given { preexisting_difference_image }
        Then { expect(difference_path).to_not be_exist }
      end
    end

    context "with trivial example description" do
      Given do
        RSpec::Core::Example.any_instance.stubs :metadata => {
          file_path: __FILE__,
          description: "Then expect(page).to match_reference_screenshot",
          example_group: { description: "parent" }
        }
      end
      Then { expect(@driver).to have_received(:save_screenshot).with(Pathname.new("tmp/spec/reference_screenshots/parent/test.png"), @opts) }
      Then { expect(@error.message).to include "Missing reference screenshot spec/reference_screenshots/parent/expected.png" }
    end

    context "with page size configuration" do
      Given do
        RSpec::PageRegression.configure do |config|
          config.viewports = [123, 456]
        end
      end
      Then { expect(@driver).to have_received(:resize).with(123, 456) }
    end

  end

  context "using expect().to_not" do
    When {
      begin
        expect(@page).to_not match_reference_screenshot
      rescue RSpec::Expectations::ExpectationNotMetError => e
        @error = e
      end
    }

    context "when files don't match" do
      Given { use_test_screenshot "A" }
      Given { use_reference_screenshot "B" }

      Then { expect(@error).to be_nil }
    end

    context "when files match" do
      Given { use_test_screenshot "A" }
      Given { use_reference_screenshot "A" }

      Then { expect(@error).to_not be_nil }
      Then { expect(@error.message).to eq "Test screenshot expected to not match reference screenshot" }
    end
  end

  def fixture_screenshot(name)
    FixturesDir + "#{name}.png"
  end

  def use_fixture_screenshot(name, path)
    path.dirname.mkpath unless path.dirname.exist?
    FileUtils.cp fixture_screenshot(name), path
  end

  def create_existing_difference_image
  end

  def use_test_screenshot(name)
    use_fixture_screenshot(name, test_path)
  end

  def use_reference_screenshot(name)
    use_fixture_screenshot(name, reference_screenshot_path)
  end

  def preexisting_difference_image
    difference_path.dirname.mkpath unless difference_path.dirname.exist?
    FileUtils.touch difference_path
  end

  def viewer_pattern(*paths)
    %r{
      \b
      (open|feh|display|viewer)
      \s
      #{paths.map{|path| Regexp.escape(path.to_s)}.join('\s')}
      \s*$
    }x
  end


end
