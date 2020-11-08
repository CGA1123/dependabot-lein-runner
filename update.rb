# Taken from dependabot/update-script
# Modified to only support dependabot-lein
# And add support for github maven repository

require "dependabot/file_fetchers"
require "dependabot/file_parsers"
require "dependabot/update_checkers"
require "dependabot/file_updaters"
require "dependabot/pull_request_creator"
require "dependabot/lein"
require "dependabot/maven"

github_maven_registries = ENV.fetch("GITHUB_MAVEN_REGISTRIES", "").split(",").map do |url|
  {
    "type" => "maven_repository",
    "url" => url,
    "username" => "x-access-token",
    "password" => ENV["GITHUB_TOKEN"]
  }
end

credentials = [
  {
    "type" => "git_source",
    "host" => "github.com",
    "username" => "x-access-token",
    "password" => ENV["GITHUB_TOKEN"]
  },
  *github_maven_registries
]

repo_name = ENV["GITHUB_REPO"]
directory = ENV["DIRECTORY_PATH"] || "/"
package_manager = "lein"

source = Dependabot::Source.new(
  provider: "github",
  repo: repo_name,
  directory: directory,
  branch: nil,
)

##############################
# Fetch the dependency files #
##############################
puts "Fetching #{package_manager} dependency files for #{repo_name}"
fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
  source: source,
  credentials: credentials,
)

files = fetcher.files
commit = fetcher.commit

##############################
# Parse the dependency files #
##############################
puts "Parsing dependencies information"
parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
  dependency_files: files,
  source: source,
  credentials: credentials,
)

dependencies = parser.parse

dependencies.select(&:top_level?).each do |dep|
  #########################################
  # Get update details for the dependency #
  #########################################
  checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
    dependency: dep,
    dependency_files: files,
    credentials: credentials,
  )

  next if checker.up_to_date?

  requirements_to_unlock =
    if !checker.requirements_unlocked_or_can_be?
      if checker.can_update?(requirements_to_unlock: :none) then :none
      else :update_not_possible
      end
    elsif checker.can_update?(requirements_to_unlock: :own) then :own
    elsif checker.can_update?(requirements_to_unlock: :all) then :all
    else :update_not_possible
    end

  next if requirements_to_unlock == :update_not_possible

  updated_deps = checker.updated_dependencies(
    requirements_to_unlock: requirements_to_unlock
  )

  #####################################
  # Generate updated dependency files #
  #####################################
  print "  - Updating #{dep.name} (from #{dep.version})…"
  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
    dependencies: updated_deps,
    dependency_files: files,
    credentials: credentials,
  )

  updated_files = updater.updated_dependency_files

  ########################################
  # Create a pull request for the update #
  ########################################
  pr_creator = Dependabot::PullRequestCreator.new(
    source: source,
    base_commit: commit,
    dependencies: updated_deps,
    files: updated_files,
    credentials: credentials,
    assignees: [(ENV["PULL_REQUESTS_ASSIGNEE"] || ENV["GITLAB_ASSIGNEE_ID"])&.to_i],
    label_language: true,
  )
  pull_request = pr_creator.create
  puts " submitted"
rescue Dependabot::PrivateSourceAuthenticationFailure => e
  puts "Failed to updated #{e.message}"
end

puts "Done"
