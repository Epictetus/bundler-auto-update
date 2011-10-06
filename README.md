# bundler-auto-update

`bundler-auto-update` is a ruby gem that updates the gems listed in your Gemfile to the latest version that does not break your system.

`bundler-auto-updates` iterates over the gems listed in your Gemfile. It updates them to their latest patch, then minor, then major version. It runs your test suite and it commit changes if successfull or revert changes otherwise.


## Install

    gem install bundler-auto-update

## Usage

    bundle-auto-update

The default test suite command is `rake`.  You can specify a custom one with the `-c` option

    bundle-auto-update -c rake test:all

## Sample output

<pre>
$> bundle-auto-update -c rake spec features

  Updating devise
    - Updating to patch version 1.1.9
    - Test suite ran successfully.
    - Committing changes

    - Updating to minor version 1.4.7
    - Test suite failed to run.
    - Reverting changes

  Updating rspec
    - Updating to patch version 2.5.1
    # [...]
</pre>

<pre>
$> git log
  02cfb8c Auto update parallel to version 0.5.9 (16 hours ago) <Hudson>
  ff39287 Auto update cucumber to version 1.1.0 (16 hours ago) <Hudson>
  3502a14 Auto update cucumber to version 0.10.7 (16 hours ago) <Hudson>
  2ff938c Auto update cucumber to version 0.9.4 (17 hours ago) <Hudson>
  800ad84 Auto update hpricot to version 0.8.4 (17 hours ago) <Hudson>
  5c92bf0 Auto update whenever to version 0.6.8 (17 hours ago) <Hudson>
  d83172d Auto update addressable to version 2.2.6 (17 hours ago) <Hudson>
  7dc3b72 Auto update fastercsv to version 1.5.4 (18 hours ago) <Hudson>
  08ae945 Auto update compass to version 0.11.5 (19 hours ago) <Philippe Creux>
  fe17166 Auto update hoptoad_notifier to version 2.4.11 (20 hours ago) <Philippe Creux>
  5875d1a Auto update hoptoad_notifier to version 2.3.12 (21 hours ago) <Philippe Creux>
  4388e07 Auto update activeadmin to version 0.3.2 (21 hours ago) <Philippe Creux>
  4cd1d0e Auto update haml to version 3.1.3 (22 hours ago) <Philippe Creux>
</pre>

## License

MIT

## Copyright

Copyright (c) 2011 VersaPay, Philippe Creux.

