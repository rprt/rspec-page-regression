module RSpec::PageRegression
  module Renderer

    def self.render(page, test_screenshot_path)

      test_screenshot_path.dirname.mkpath unless test_screenshot_path.dirname.exist?
      # Capybara doesn't implement resize in API
      unless page.driver.respond_to? :resize
        page.driver.browser.manage.window.resize_to *RSpec::PageRegression.viewports
      else
        page.driver.resize *RSpec::PageRegression.viewports
      end
      page.driver.save_screenshot test_screenshot_path, :full => true
    end
  end
end
