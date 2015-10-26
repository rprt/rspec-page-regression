require 'spec_helper'
require 'fileutils'

describe 'match_reference_screenshot with viewport management' do
  Given { initialize_spec }
  When { expect_to_statement }

  context 'with config.viewports configuration' do
    context 'with one viewport' do
      around(:each) do |example|
        with_config_viewports(viewports: { small: [123, 456] }) do
           example.run
        end
      end

      Then { expect(@driver).to have_received(:resize).with(123, 456) }
    end

    context 'with multiple viewports' do
      around(:each) do |example|
        with_config_viewports(viewports: { tablet: [1024, 768], mobile: [480, 320] }) do
          use_test_screenshot('A', 'tablet')
          use_test_screenshot('A', 'mobile')
          example.run
        end
      end

      context 'should receive 2 resizes' do
        Then { expect(@driver).to have_received(:resize).with(1024, 768) }
        Then { expect(@driver).to have_received(:resize).with(480, 320) }
      end

      context 'fails when all the expected files are missing' do
        Then { expect(@error.message).to include "Missing reference screenshot #{reference_screenshot_path('tablet')}" }
        Then { expect(@error.message).to include "Missing reference screenshot #{reference_screenshot_path('mobile')}" }
      end

      context 'fails when one of the expected files are missing' do
        Given { use_reference_screenshot('A', 'tablet') }
        Then { expect(@error.message).to_not include "Missing reference screenshot #{reference_screenshot_path('tablet')}" }
        Then { expect(@error.message).to include "Missing reference screenshot #{reference_screenshot_path('mobile')}" }
      end

      context 'passes when expectation matches in all page sizes' do
        Given do
          use_reference_screenshot('A', 'tablet')
          use_reference_screenshot('A', 'mobile')
        end
        Then { expect(@error).to be_nil }
      end

      context 'fails when expectation does not match atleast one of the page sizes' do
        Given do
          use_reference_screenshot('A', 'tablet')
          use_reference_screenshot('B', 'mobile')
        end
        Then { expect(@error.message).to include 'Test screenshot does not match reference screenshot' }
        Then { expect(@error.message).to include "#{reference_screenshot_path('mobile')}" }
        Then { expect(@error.message).to_not include "#{reference_screenshot_path('tablet')}" }
      end
    end
  end
end
