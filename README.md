# rspec-page-regression

Rspec-page-regression is an [RSpec](https://github.com/rspec/rspec) plugin
that makes it easy to regression test your web application pages, to make
sure the pages continue to look the way you expect them to look.

[<img src="https://secure.travis-ci.org/ronen/rspec-page-regression.png"/>](http://travis-ci.org/ronen/rspec-page-regression)[<img src="https://gemnasium.com/ronen/rspec-page-regression.png" alt="Dependency Status" />](https://gemnasium.com/ronen/rspec-page-regression)

## Installation

Rspec-page-regression uses [PhantomJS](http://www.phantomjs.org/) to render web page snapshots, by virtue of the [Poltergeist](https://github.com/jnicklas/capybara) driver for [Capybara](https://github.com/jnicklas/capybara).  Assuming you have those installed and ready to go...

In your Gemfile:

    gem 'rspec-page-regression'

And in your spec_helper:

    require 'rspec'
    require 'rspec/page-regression'

Rspec-page-regression presupposes the convention that your spec files are under a directory named `spec` (checked in to your repo), with a sibling directory `tmp` (.gitignore'd)

## Usage

Rspec-page-regression provides a matcher that renders the page and compares
the resulting image against an expected image.  To use it, you need to enable
Capybara and Poltergeist by specifying `:type => :feature` and `:js => true`:

    describe "my page", :type => :feature, :js => true do

      before(:each) do
        visit my_page_path
      end

      it { page.should match_expectation }

      context "popup help" do
        before(:each) do
          click_button "Help"
        end

        it { page.should match_expectation }
      end
    end
    
The spec will pass if the test rendered image contains the  exact same pixel values as the expectated image.  Otherwise it will fail with an error message along the lines of:

    Test image does not match expected image
       $ open tmp/spec/expectation/my_page/popup_help/test.png spec/expectation/my_page/popup_help/expected.png tmp/spec/expectation/my_page/popup_help/difference.png

Notice that the second line gives a command you can copy and paste in order to visually compare the test and expected images.

It also shows a "difference image" in which each pixel contains the per-channel absolute difference between the test and expected images.  That is, the difference images is black everywhere except has some funky colored pixels where the test and expected images differ.  To help you locate those, it also has a red bounding box drawn around the region with differences.

### How do you create expectation images?

The easiest way to create an expectation image is to run the test for the first time and let it fail.  You'll then get a failure message like:

    Missing expectation image spec/expectation/my_page/popup_help/expected.png
        $ open tmp/spec/expectation/my_page/popup_help/test.png
    To create it:
        $ mkdir -p spec/expectation/my_page/popup_help && cp tmp/spec/expectation/my_page/popup_help/test.png spec/expectation/my_page/popup_help/expected.png

First view the image to make sure it really is what you expect.  Then copy and paste the last line to install it.  (And then of course commit it into your repository.)

### How do you update expectation images?

If you've deliberatly changed something that affects the look of your web page, then your regression test will fail.  The "test" image will contain the new look, and the "expected" image will contain the old.

Once you've visually checked the test image to make sure it's really what you want, then simply copy the test image over the old expectation image.  (And then of course commit it it into your repository.)

The failure message doesn't include a ready-to-copy-and-paste `$ cp` command, but you can copy and paste the individual file paths from the "does not match" message.  (The reason not to have a ready-to-copy-and-paste command is if the failure is real, it shouldn't be too easy to mindlessly copy and paste to make it go away.)

### Where are the expectation images?

As per the above examples, the expectation images default to being stored under `spec/expectation`, with the remainder of the path constructed from the example group descriptions. (If the `it` also has a description it will be used as well.)

If that default scheme doesn't suit you, you can pass a path to where the expectation image should be found:

    page.should match_expectation "/path/to/my/file.png"

Everything will work normally, and the failure messages will refer to your path.

## Configuration

The default window size for the renders is 1024 x 768.  You can specify another size as `[height, width]` in pixels:

     # in spec_helper.rb:
     RSpec::PageRecression.configure do |config|
       config.page_size = [1280, 1024]
     end

Note that this specifies the size of the browser window viewport; but rspec-page-regression requests a render of the full page, which might extend beyond the window.  So the rendered file sizes may be larger than this configuration value.


## Contributing

Contributions are welcome!  As usual, here's the drill:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Don't forget to include specs (`rake spec`) to verify your functionality.  Code coverage should be 100%