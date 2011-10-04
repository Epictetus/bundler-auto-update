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
    Then the output should contain:
      """
      Updating dmg.
        - Updating to patch version 0.0.4
      rake
        - Test suite failed to run. Reverting changes.
      git reset --hard Gemfile Gemfile.lock
      """

  Scenario: Auto Update with custom command
    Given a file named "Gemfile" with:
    """
    source "http://rubygems.org"

    gem 'dmg', '0.0.2'
    """
    When I run `bundle install`
    Then the output should contain "dmg (0.0.2) "
    Then the output should contain "complete!"

    When I run `git init`
    When I run `git add .`
    When I run `git commit -a -m "Initial Commit"`

    When I run `bundle-auto-update -c echo Hello`
    Then the output should contain:
      """
      Updating dmg.
        - Updating to patch version 0.0.4
      rake
      echo Hello
      Hello
        - Test suite ran succesfully. Committing changes.
      """

