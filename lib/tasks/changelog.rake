# frozen_string_literal: true

require "github_changelog_generator/task"

# The generator only retries GitHub rate-limit errors (Octokit::Forbidden).
# It makes thousands of API calls across 25 threads, so a single dropped
# connection (SSL "unexpected eof") otherwise aborts the whole run.
module ChangelogNetworkRetry
  def retry_options
    super.tap do |options|
      options[:on] += [Faraday::SSLError, Faraday::ConnectionFailed, OpenSSL::SSL::SSLError]
    end
  end
end

GitHubChangelogGenerator::OctoFetcher.prepend(ChangelogNetworkRetry)

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = "defra"
  config.project = "waste-carriers-engine"
end
