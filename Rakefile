# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'tasks/tog'


namespace :spec do
  desc "Add files that DHH doesn't consider to be 'code' to stats"
  task :statsetup do
  require 'code_statistics'

  class CodeStatistics
    alias calculate_statistics_orig calculate_statistics
    def calculate_statistics
      @pairs.inject({}) do |stats, pair|
        if 3 == pair.size
          stats[pair.first] = calculate_directory_statistics(pair[1], pair[2]); stats
        else
          stats[pair.first] = calculate_directory_statistics(pair.last); stats
        end
      end
    end
  end
  ::STATS_DIRECTORIES << ['Views',  'app/views', /\.(rhtml|erb|rb)$/]
  ::STATS_DIRECTORIES << ['Test Fixtures',  'test/fixtures', /\.yml$/]
  ::STATS_DIRECTORIES << ['Email Fixtures',  'test/fixtures', /\.txt$/]
  # note, I renamed all my rails-generated email fixtures to add .txt
  ::STATS_DIRECTORIES << ['Static HTML', 'public', /\.html$/]
  # ::STATS_DIRECTORIES << ['Static CSS',  'public', /\.css$/]
  # ::STATS_DIRECTORIES << ['Static JS',  'public', /\.js$/]
  # prototype is ~5384 LOC all by itself - very hard to filter out

  ::CodeStatistics::TEST_TYPES << "Test Fixtures"
  ::CodeStatistics::TEST_TYPES << "Email Fixtures"
  end
end
task :stats => "spec:statsetup"