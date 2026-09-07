# frozen_string_literal: true

# Pin Mongoid's behaviour flags to their 8.0 values. This is a no-op on
# Mongoid 8.1 and keeps the Rails 8.1 / Mongoid 9.1 gem bump behaviour-neutral;
# the flags are then walked 8.0 -> 8.1 -> 9.0 -> 9.1 in separate, suite-verified
# steps. See .claude/docs/rails-8.1-upgrade-phase0-dependency-verification.md (ADR-002).
Mongoid.configure do |config|
  config.load_defaults 8.0
end
