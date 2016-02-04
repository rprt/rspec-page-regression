require 'spec_helper'
require 'fileutils'

describe 'match_reference_screenshot' do
  Given { initialize_spec }

  context "using expect().to" do
    Given { @args = nil }
    When { perform_screenshot_match(@args) }

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

      context "with selector" do
        Given { @args = { selector: "#foo" } }

        Then { expect(@driver).to have_received(:save_screenshot).with(anything, selector: "#foo") }
      end

      context "without selector" do
        Then { expect(@driver).to have_received(:save_screenshot).with(anything, full: true) }
      end

      context "with full: false" do
        Given { @args = { full: false } }

        Then { expect(@driver).to have_received(:save_screenshot).with(anything, full: false) }
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

    context "with trivial example description" do
      Given do
        RSpec::Core::Example.any_instance.stubs :metadata => {
          file_path: __FILE__,
          description: "Then expect(page).to match_reference_screenshot",
          example_group: { description: "parent" }
        }
      end
      Then { expect(@driver).to have_received(:save_screenshot).with(Pathname.new("tmp/spec/reference_screenshots/parent/#{file_name('test')}.png"), @opts) }
      Then { expect(@error.message).to include 'Missing reference screenshot spec/reference_screenshots/parent/expected' }
    end

    context "with label option" do
      Given { @args = { label: 'label'} }
      Given do
        RSpec::Core::Example.any_instance.stubs :metadata => {
          file_path: __FILE__,
          description: "Then expect(page).to match_reference_screenshot",
          example_group: { description: "parent" }
        }
      end

      Then { expect(@driver).to have_received(:save_screenshot).with(Pathname.new("tmp/spec/reference_screenshots/parent/test-label.png"), @opts) }
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
end
