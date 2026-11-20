source "https://rubygems.org"

# The site generator. GitHub Actions builds with exactly the versions in Gemfile.lock.
gem "jekyll", "~> 4.4"

# Needed by `jekyll serve` on Ruby 3.
gem "webrick", "~> 1.9"

group :test do
  # Checks internal links, images and alt text in the built site.
  gem "html-proofer", "~> 5.2"
end
