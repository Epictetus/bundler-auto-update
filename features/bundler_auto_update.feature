Feature: Auto update Gemfile

  As a developer
  In order to keep my application up to date
  I want Bundler AutoUpdate to attempt to update every single gem of my Gemfile

  Background:
    Given a file named "Gemfile" with:
    """
    source "http://rubygems.org"

    gem 'dmg', '0.0.2'
    """
    When I run `bundle install`
    Then the output should contain "dmg (0.0.2) "
    Then the output should contain "complete!"


  Scenario: Auto Update
    When I run `bundle-auto-update`
    Then the output should contain:
      """
      Updating dmg.
        - Updating to patch version 0.0.4
      """
    Then the output should contain:
      """
      rake
        - Test suite failed to run. Reverting changes.
      git checkout Gemfile Gemfile.lock
      """

  Scenario: Auto Update with custom command
    When I run `git init`
    When I run `git add .`
    When I run `git commit -a -m "Initial Commit"`

    When I run `bundle-auto-update -c echo Hello`
    Then the output should contain:
      """
      Updating dmg.
        - Updating to patch version 0.0.4
      """
    Then the output should contain:
      """
      echo Hello
      Hello
        - Test suite ran successfully. Committing changes.
      git commit Gemfile Gemfile.lock -m 'Auto update dmg to version 0.0.4'
      """
    When I run `git log`
    Then the output should contain "Auto update dmg to version 0.0.4"

