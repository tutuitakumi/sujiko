# frozen_string_literal: true

require_relative "lib/sujiko/version"

Gem::Specification.new do |spec|
  spec.name = "sujiko"
  spec.version = Sujiko::VERSION
  spec.authors = ["tutuitakumi"]
  spec.email = ["takumi.github@gmail.com"]

  spec.summary = "Joke/toy gem: local dev server for a venue meetup map (GET /?shape&x&y). Not for production."
  spec.description = <<~DESC.strip
    Sujiko is a joke / toy Ruby gem: a small TCP server for local development, not for serious or
    production use. It serves one page: a venue floor plan where
    a meetup point is shown. Open GET / with optional query parameters shape, x, and y—the same
    contract as a Rails Spots-style app and iOS: shape selects the room (e.g. roomA, with
    normalization to internal ids like room_a); x and y are normalized coordinates from 0.0 to 1.0
    (top-left of the white floor, independent of device pixels). Use it to preview map UI and to
    build or verify share URLs (Safari, copy, etc.) before deploying.
  DESC
  spec.homepage = "https://github.com/tutuitakumi/sujiko"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
