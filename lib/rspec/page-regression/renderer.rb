module RSpec::PageRegression
  module Renderer

    def self.render(page, filepaths)
      test_screenshot_path = filepaths.test_screenshot
      test_screenshot_path.dirname.mkpath unless test_screenshot_path.dirname.exist?
      # Capybara doesn't implement resize in API
      unless page.driver.respond_to? :resize
        page.driver.browser.manage.window.resize_to *filepaths.viewport[1]
      else
        page.driver.resize *filepaths.viewport[1]
      end
      page.driver.save_screenshot test_screenshot_path, :full => true
    end

    def self.render_responsive(page, responsive_filepaths)
      responsive_filepaths.each { |fp| render(page, fp) }
    end
  end
end
