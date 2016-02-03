module RSpec::PageRegression
  module Renderer

    def self.render(page, filepaths, options = {})
      test_screenshot_path = filepaths.test_screenshot
      test_screenshot_path.dirname.mkpath unless test_screenshot_path.dirname.exist?
      # Capybara doesn't implement resize in API
      unless page.driver.respond_to? :resize
        page.driver.browser.manage.window.resize_to *filepaths.viewport.size
      else
        page.driver.resize *filepaths.viewport.size
      end
      options = { full: true }.merge(options)
      options.delete(:full) if options.key?(:selector)
      page.driver.save_screenshot test_screenshot_path, options
    end

    def self.render_responsive(page, responsive_filepaths, opt)
      responsive_filepaths.each { |fp| render(page, fp, opt) }
    end
  end
end
