require 'yard'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc 'Run RSpec code examples in specdoc mode'
  RSpec::Core::RakeTask.new(:doc) do |t|
    t.rspec_opts = %w(--backtrace --colour --format doc)
  end
end

namespace :doc do
  YARD::Rake::YardocTask.new

  desc 'Generate HTML report specs'
  RSpec::Core::RakeTask.new("spec") do |spec|
    spec.rspec_opts = ["--format", "html", "-o", "doc/spec.html"]
  end
end

task test: :spec
task specs: :spec

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do |task|
    task.options = ["-DS"]
  end

  task default: [:spec, :rubocop]
rescue LoadError
  # RuboCop isn't installed on Ruby versions older than 2.7
  task default: :spec
end
