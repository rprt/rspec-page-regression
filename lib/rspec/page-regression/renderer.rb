module RSpec::PageRegression
  module Renderer

    def self.render(page, test_image_path)

      test_image_path.dirname.mkpath unless test_image_path.dirname.exist?
      page.driver.resize *RSpec::PageRegression.page_size
      page.driver.render test_image_path, :full => true
    end
  end
end
