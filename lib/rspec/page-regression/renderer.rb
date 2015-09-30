module RSpec::PageRegression
  module Renderer

    def self.render(page, test_screenshot_path)

      test_screenshot_path.dirname.mkpath unless test_screenshot_path.dirname.exist?
      # Capybara doesn't implement resize in API
      unless page.driver.respond_to? :resize
        page.driver.browser.manage.window.resize_to *RSpec::PageRegression.page_size
      else
        page.driver.resize *RSpec::PageRegression.page_size
      end
      page.driver.save_screenshot test_screenshot_path, :full => true
    end
  end
end
