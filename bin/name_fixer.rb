#!/usr/bin/env ruby

=begin

=end

require 'find'
require 'fileutils'

# PRESUMPTION: that this script is located within a first-level child
# subdir of the project (e.g. './bin')
BASE_PATH              = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

COFFEECHERRIES_SEGMENT = 'coffeecherries'
TEST_SEGMENT           = 'test'
COFFEECHERRIES_PATH    = File.join(BASE_PATH, COFFEECHERRIES_SEGMENT)
TEST_PATH              = File.join(BASE_PATH, TEST_SEGMENT)

#================================================================================
def carp!(msg)
  puts(msg)
  exit(1)
end

#================================================================================
def split_path(p)
  return p.split(File::SEPARATOR).select {|e| not e.empty?}
end

#================================================================================
def join_path(p)
  return sprintf("%s%s", File::SEPARATOR, p.join(File::SEPARATOR))
end

#================================================================================
def rename_paths(starting_path, lowercase_spec)
  paths_to_rename = []
  Find.find(starting_path) do |dir_entry|
    next if not FileTest.directory?(dir_entry)
    next if split_path(dir_entry).last != 'fixme'
    paths_to_rename << dir_entry
  end
  paths_to_rename.sort! {|x,y| y.length <=> x.length}
  paths_to_rename.each do |current_path|
    t = split_path(current_path)
    t.pop
    t.push(lowercase_spec)
    new_path = join_path(t)
    FileUtils::Verbose.mv(current_path, new_path)
  end
end

#================================================================================
def parse_content(file_spec, lowercase_spec, classname_spec)
  printf("parsing: %s\n", file_spec)
  lines = File.readlines(file_spec)
  line_count = 0
  lines.each do |line|
    line_count += 1
    orig_line = line.dup
    line.gsub!(/fixme/, lowercase_spec)
    line.gsub!(/Fixme/, classname_spec)
    printf("  mod line %d: |%s|\n", line_count, line.chomp) if orig_line != line
  end
  f = File.new(file_spec, "w")
  f.write(lines.join())
  f.close()
end

#================================================================================
def rename_content(starting_path, lowercase_spec, classname_spec)
  Find.find(starting_path) do |dir_entry|
    next if not FileTest.file?(dir_entry)
    next if not ['.coffee', '.html'].include?(File.extname(dir_entry))
    parse_content(dir_entry, lowercase_spec, classname_spec)
  end
end

#================================================================================
#==== main
#================================================================================
if __FILE__ == $0

  $stderr.sync = true
  $stdout.sync = true

  # sanity checks

  carp!('source subtree not found') if (not File.exists?(COFFEECHERRIES_PATH))
  carp!('test subtree not found') if (not File.exists?(TEST_PATH))

  # process command-line parameters

  lowercase_spec = ARGV.shift
  carp!("missing parameter: lowercase_spec") if lowercase_spec.nil?
  classname_spec = ARGV.shift
  carp!("missing parameter: classname_spec") if classname_spec.nil?

  # rename 'fixme' paths

  printf("==== rename 'fixme' paths to lowercase form\n")
  rename_paths(COFFEECHERRIES_PATH, lowercase_spec)
  rename_paths(TEST_PATH, lowercase_spec)

  # fix lowercase and classname content hits

  printf("==== rename 'fixme' and 'Fixme' content to new form\n")
  parse_content(File.join(BASE_PATH, 'config.coffee'), lowercase_spec, classname_spec)
  rename_content(COFFEECHERRIES_PATH, lowercase_spec, classname_spec)
  rename_content(TEST_PATH, lowercase_spec, classname_spec)

end
