Feature: Auto update Gemfile

  As a developer
  In order to keep my application up to date
  I want Bundler AutoUpdate to attempt to update every single gem of my Gemfile

  Scenario: Auto Update
    Given a file named "Gemfile" with:
    """
    source "http://rubygems.org"

    gem 'dmg', '0.0.2'
    """
    When I run `bundle install`
    Then the output should contain "dmg (0.0.2) "
    Then the output should contain "complete!"

    When I run `bundle-auto-update`
    Then the output should contain "wtf!"

