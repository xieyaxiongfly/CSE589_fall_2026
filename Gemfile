source "https://rubygems.org"

# Local preview only. GitHub Pages builds this site server-side with its own
# pinned gem set and ignores this file, so the versions here just need to run
# on a current Ruby.
#
# The github-pages gem is deliberately NOT used: it pins Jekyll 3.9 / Liquid
# 4.0.3 (2020), which call String#tainted? and require csv from the stdlib --
# both removed in modern Ruby, so they cannot run on Ruby 4.
#
#     cd dashboard && ./start-site.sh

gem "jekyll", "~> 4.3"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows and JRuby do not include zoneinfo files.
install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?

# Ruby 4.x unbundled these from the stdlib; some gems still expect them.
gem "csv"
gem "base64"
gem "bigdecimal"
gem "logger"
gem "ostruct"
