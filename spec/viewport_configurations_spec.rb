require 'spec_helper'
require 'fileutils'

describe 'match_reference_screenshot with viewport management' do
  Given { initialize_spec }

  context 'with invalid arguments' do
    Then { expect{ expect_to_statement(invalid: :argument) }.to raise_error(ArgumentError) }
    Then { expect{ expect_to_statement('invalid_argument') }.to raise_error(ArgumentError) }
  end

  context 'with config.viewports configuration' do
    When { expect_to_statement }

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

  context 'with config.viewports and config.default_viewports' do
    around(:each) do |example|
      viewports = { wide: [1440, 990], large: [1280, 720], medium: [1024, 768], small: [480, 320] }
      defaults = [:small, :medium]
      with_config_viewports(viewports: viewports, default_viewports: defaults) do
        example.run
      end
    end

    context 'should receive 2 resizes' do
      When { expect_to_statement }
      Then { expect(@driver).to have_received(:resize).with(1024, 768) }
      Then { expect(@driver).to have_received(:resize).with(480, 320) }
    end

    context 'choose a different viewport for a match statement' do
      match_argument = { viewport: :wide }
      When { expect_to_statement(match_argument) }
      Then { expect(@driver).to have_received(:resize).with(1440, 990) }
    end

    context 'choose different viewports for match a statement' do
      match_argument = { viewport: [:wide, :large] }
      When { expect_to_statement(match_argument) }
      Then { expect(@driver).to have_received(:resize).with(1440, 990) }
      Then { expect(@driver).to have_received(:resize).with(1280, 720) }
    end

    context 'leave out a viewport for a match statement' do
      match_argument = { except_viewport: :small }
      When { expect_to_statement(match_argument) }
      Then { expect(@driver).to have_received(:resize).with(1440, 990) }
      Then { expect(@driver).to have_received(:resize).with(1280, 720) }
      Then { expect(@driver).to have_received(:resize).with(1024, 768) }
    end

    context 'leave out multiple viewports for a match statement' do
      match_argument = { except_viewport: [:wide, :large, :medium] }
      When { expect_to_statement(match_argument) }
      Then { expect(@driver).to have_received(:resize).with(480, 320) }
    end
  end
end
