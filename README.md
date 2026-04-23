# Sujiko

**当然ジョーク用（お遊び）の gem です**  
**This is a joke / toy gem — for fun and local experiments, not for production use.**

A local development server for a **venue meetup map**: one `GET /` page with optional query parameters `shape`, `x`, and `y` (same rules as a Rails `SpotsController`-style app and the iOS URL builder). Normalized coordinates `0.0`–`1.0` with the top-left of the white floor as origin; `shape` picks the room (e.g. `roomA` → `room_a` after normalization). The server listens on `127.0.0.1` and, on macOS, opens your default browser on startup.

Example: `http://127.0.0.1:4567/?shape=roomA&x=0.3&y=0.4`

## Installation

With Bundler, add to your `Gemfile`:

```bash
bundle add sujiko
```

Without Bundler:

```bash
gem install sujiko
```

## Usage

### CLI

```bash
sujiko                    # default port 4567
sujiko 3000              # custom port
```

`--public-origin` / `-o` sets the **origin** (scheme, host, optional non-default port only—no path, query, or userinfo) for **copied** “meetup” URLs. If omitted, the page uses the browser’s current `location.origin`, same as before.

From a cloned repository:

```bash
bundle exec sujiko
```

| Environment | Effect |
|-------------|--------|
| `SUJIKO_NO_BROWSER` | If set, the server does not open a browser on startup. |

### `GET /` query parameters

| Name | Meaning |
|------|---------|
| `shape` | Venue id (e.g. `roomA`); normalized server-side to internal ids like `room_a` / `room_b` / `room_c` / `room_main`. |
| `x`, `y` | Normalized position on the white floor, each `0.0`–`1.0` (clamped; parse failures fall back to `0.5`). |

The page reads these from the URL on load; use **Copy** in the UI to get a `?shape&x&y` link you can open in Safari or share. The copied URL’s **origin** follows `--public-origin` when the server was started with it; otherwise it matches the page you are viewing.

### Programmatically

```ruby
require "sujiko"

Sujiko::Server.start
Sujiko::Server.start(port: 8080)
```

Press `Ctrl-C` to stop the server.

## Development

After checkout, run `bin/setup` to install dependencies. Use `bin/console` for an interactive session.

`bundle exec rake install` installs the gem locally. To release, bump the version in `lib/sujiko/version.rb` and run `bundle exec rake release` (creates a git tag, pushes commits, uploads the `.gem` to [rubygems.org](https://rubygems.org)).

## Contributing

Bug reports and pull requests are welcome on GitHub: https://github.com/tutuitakumi/sujiko

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
