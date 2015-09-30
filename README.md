
[![Gem Version](https://badge.fury.io/rb/rspec-page-regression.png)](http://badge.fury.io/rb/rspec-page-regression)
[![Build Status](https://secure.travis-ci.org/ronen/rspec-page-regression.png)](http://travis-ci.org/ronen/rspec-page-regression)
[![Dependency Status](https://gemnasium.com/ronen/rspec-page-regression.png)](https://gemnasium.com/ronen/rspec-page-regression)

# rspec-page-regression


Rspec-page-regression is an [RSpec](https://github.com/rspec/rspec) plugin
that makes it easy to headlessly regression test your web application pages to make sure the pages continue to look the way you expect them to look, taking into account HTML, CSS, and JavaScript.

It provides an RSpec matcher that compares the test screenshot to a reference screenshot, and facilitates management of the screenshots.

Rspec-page-regression uses [PhantomJS](http://www.phantomjs.org/) to headlessly render web page screenshots, by virtue of the [Poltergeist](https://github.com/jonleighton/poltergeist) driver for [Capybara](https://github.com/jnicklas/capybara).  You can also use the Selenium driver to test against real browsers.

Rspec-page-regression is tested on ruby 1.9.3, 2.1.0, and jruby

## Installation


Install PhantomJS as per [PhantomJS: Download and Install](http://phantomjs.org/download.html) and/or [Poltergeist: Installing PhantomJS](https://github.com/jonleighton/poltergeist#installing-phantomjs).  There are no other external dependencies (no need for Qt, nor an X server, nor ImageMagick, etc.)

In your Gemfile:

    gem 'rspec-page-regression'

And in your spec_helper:

    require 'rspec'  # or 'rspec/rails' if you're using Rails
    require 'rspec/page-regression'

	require 'capybara/rspec'
	require 'capybara/poltergeist'
	Capybara.javascript_driver = :poltergeist

Rspec-page-regression presupposes the convention that your spec files are somwhere under a directory named `spec` (checked in to your repo), which has a sibling directory `tmp` (.gitignore'd)

To install for use with Selenium, [see instructions below](#selenium).

#### Note on versions
Rspec-page-regression has multiple versions that work in concert with the [significant changes in RSpec version 3](http://myronmars.to/n/dev-blog/2013/07/the-plan-for-rspec-3).  If you're using bundler, the gem dependencies should automatically find the proper version of rspec-page-regression for your chosen version of RSpec.

| Rspec Version | Rspec-page-regression |
| ------------- | --------------------- |
| >= 3.0.*      | >= 0.3.0			    |
| 2.99          | 0.2.99                |
| <= 2.14.*     | <= 0.2.1              |


### Upgrading from rspec-page-regression v0.4 to v1.0
* Rename all uses of `match_expectation` to `match_reference_screenshot` in your sources.
* Delete the directories `spec/expectation` and `tmp/spec/expectation`
* Make sure that the configuration flag `autocreate_reference_screenshots` is set to true (this is the default). # TODO: Depends on finishing issue #22
* Run all specs. A new directory `reference_screenshots` directory with up to date screenshots will be created automatically.
* Check that all screenshots look ok prior to committing them.

## Usage

Rspec-page-regression provides a matcher that renders the page, takes a screenshot and compares
it against a reference screenshots.  To use it, you need to enable Capybara and Poltergeist by specifying `:type => :feature` and `:js => true`:

    require 'spec_helper'

    describe "my page", :type => :feature, :js => true do

      before(:each) do
        visit my_page_path
      end

      it { expect(page).to match_reference_screenshot }

      context "popup help" do
        before(:each) do
          click_button "Help"
        end

        it { expect(page).to match_reference_screenshot }
      end
    end

The spec will pass if the test rendered screenshot contains the  exact same pixel values as the reference screenshot.  Otherwise it will fail with an error message along the lines of:

    Test image does not match reference screenshot
       $ open tmp/spec/reference_screenshots/my_page/popup_help/test.png spec/reference_screenshots/my_page/popup_help/expected.png tmp/spec/reference_screenshots/my_page/popup_help/difference.png

Notice that the second line gives a command you can copy and paste in order to visually compare the test and expected images.

It also shows a "difference image" in which each pixel contains the per-channel absolute difference between the test and expected images.  That is, the difference images is black everywhere except has some funky colored pixels where the test and expected images differ.  To help you locate those, it also has a red bounding box drawn around the region with differences.

### How do I create reference screenshots?

The easiest way to create a reference screenshot is to run the test for the first time and let it fail.  You'll then get a failure message like:

    Missing reference screenshot spec/reference_screenshots/my_page/popup_help/expected.png
        $ open tmp/spec/reference_screenshots/my_page/popup_help/test.png
    To create it:
        $ mkdir -p spec/reference_screenshots/my_page/popup_help && cp tmp/spec/reference_screenshots/my_page/popup_help/test.png spec/reference_screenshots/my_page/popup_help/expected.png

First view the test image to make sure it really is what you expect.  Then copy and paste the last line to install it as the reference screenshot.
(And then of course commit this reference screenshot into your repository.)

### How do I update reference screenshots?

If you've deliberatly changed something that affects the look of your web page, your regression test will fail.  The "test" image will contain the new look, and the "expected" image will contain the old.

Once you've visually checked the test image to make sure it's really what you want, then simply copy the test image over the old reference screenshot.  (And then of course commit it it into your repository.)

The failure message doesn't include a ready-to-copy-and-paste `cp` command, but you can copy and paste the individual file paths from the message.  (The reason not to have a ready-to-copy-and-paste command is if the failure is real, it shouldn't be too easy to mindlessly copy and paste to make it go away.)

### Where are the reference screenshots?

As per the above examples, the reference screenshots default to being stored under `spec/reference_screenshots`, with the remainder of the path constructed from the example group descriptions. (If the `it` also has a description it will be used as well.)

If that default scheme doesn't suit you, you can pass a path to where the reference screenshot should be found:

    expect(page).to match_reference_screenshot "/path/to/my/screenshot.png"

Everything will work normally, and the failure messages will refer to your path.

## Configuration

### Window size

The default window size for the renders is 1024 x 768 pixels.  You can specify another size as `[height, width]` in pixels:

     # in spec_helper.rb:
     RSpec::PageRegression.configure do |config|
       config.page_size = [1280, 1024]
     end

Note that this specifies the size of the browser window viewport; but rspec-page-regression requests a render of the full page, which might extend beyond the window.  So the rendered file dimensions may be larger than this configuration value.

### Image difference threshold

By default, a test fails if only a single pixel in the screenshot differs from the reference screenshot. To account for minor rendering differences, you can set a threshold value that allows a certain amount of differences. The threshold value is the fraction of pixels that are allowed to differ before the test fails.

    RSpec::PageRegression.configure do |config|
      config.threshold = 0.01
    end

This setting means that 1% of pixels are allowed to differ between the rendering result and the reference screenshot. For example, for an image size of 1024 x 768 and a threshold of 0.01, the maximum number of pixel differences between the images is 7864.

## [Using the selenium driver](id:selenium)

You can also use the selenium driver with capybara. This offers the possiblity to visually test your pages against a range of real browsers.

Add the [selenium-webdriver](https://rubygems.org/gems/selenium-webdriver) to your Gemfile:

    gem 'selenium-webdriver'

And in your spec_helper replace:

    require 'capybara/poltergeist'
    Capybara.javascript_driver = :poltergeist

With:

    require 'selenium/webdriver'
    Capybara.javascript_driver = :selenium


See also the [capybara readme](https://github.com/jnicklas/capybara#selenium) and [selenium wiki](https://code.google.com/p/selenium/wiki/RubyBindings) for more information.

## Contributing

Contributions are welcome!  As usual, here's the drill:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Don't forget to include specs (`rake spec`) to verify your functionality.  Code coverage should be 100%

## History

Release Notes:

* 0.4.2 - Now works with jruby.  Thanks to [@paresharma](https://github.com/paresharma)

* 0.4.1 - Bug fix: wasn't including example name in file path.  Thanks to [@kurtisnelson](https://github.com/kurtisnelson)

* 0.4.0 - Add difference threshold.  Thanks to [@abersager](https://github.com/abersager)

* 0.3.0 - Compatibility with rspec 3.0

* 0.2.99 - Compatibility with rspec 2.99

* 0.2.1 - Explicit dependency on rspec ~> 2.14.0

* 0.2.0 - Support selenium.  Thanks to [@edwinvdgraaf](https://github.com/edwinvdgraaf)

* 0.1.2 - Remove existing difference images so they won't be shown in cases where files couldn't be differenced.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ronen/rspec-page-regression/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
