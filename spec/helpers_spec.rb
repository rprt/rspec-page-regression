require 'spec_helper'
require 'fileutils'

context 'helpers' do
  context 'with default config' do
    it 'uses proper paths' do
      expect(reference_screenshot_path).to eq Pathname.new('spec/reference_screenshots/helpers/with_default_config/uses_proper_paths/expected.png')
      expect(test_path).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_default_config/uses_proper_paths/test.png')
      expect(difference_path).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_default_config/uses_proper_paths/difference.png')
    end
  end

  context 'with viewport config' do
    around(:each) do |example|
      with_config_viewports(viewports: { tablet: [1024, 768], mobile: [480, 320] }) do
        example.run
      end
    end

    it 'uses proper paths' do
      expect(reference_screenshot_path).to eq Pathname.new('spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/expected-tablet.png')
      expect(test_path).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/test-tablet.png')
      expect(difference_path).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/difference-tablet.png')
      expect(reference_screenshot_path('mobile')).to eq Pathname.new('spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/expected-mobile.png')
      expect(test_path('mobile')).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/test-mobile.png')
      expect(difference_path('mobile')).to eq Pathname.new('tmp/spec/reference_screenshots/helpers/with_viewport_config/uses_proper_paths/difference-mobile.png')
    end
  end
end

