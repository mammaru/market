# coding: utf-8
require 'yaml'

ROOT = File.expand_path(__dir__)
LOG_DIR = "#{ROOT}/log"
DATA_DIR = "#{ROOT}/data"
LIB_PATH = "#{ROOT}/lib"

# Load configuation file
CONFIG = YAML::load("#{ROOT}/config.yml")

# Load all tasks
Dir["#{ROOT}/lib/tasks/**/*.rake"].each do |path|
  load path
end

