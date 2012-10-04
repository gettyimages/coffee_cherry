#!/usr/bin/env ruby

=begin

This script rebuilds the cherry's ./docs/ tree.

As a first step, all existing content within the ./docs/ subtree is
deleted -- so, DON'T KEEP ANYTHING IN THERE!

A full-wipe is done to prevent any docco-generated .html files from
persisting as orphans should the corresponding .coffee source files be
removed or renamed.  Same applies to subdirectories created by this
script.

Docco is then applied to each .coffee file found within the cherry's
source subtree: ./coffeecherries/, and also to each .coffee file found
within the test subtree: ./test/.  The generated .html files are
populated into a subtree which mirrors the source locations.

A table-of-contents file is then generated: ./docs/index.html.

So, basically, just run this script after any project editing work to
make sure the documentation is up to date.

=end

require 'find'
require 'fileutils'
require 'pathname'
require 'set'

# PRESUMPTION: that this script is located within a first-level child
# subdir of the project (e.g. './bin')
BASE_PATH              = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

DOCS_SEGMENT           = 'docs'
COFFEECHERRIES_SEGMENT = 'coffeecherries'
TEST_SEGMENT           = 'test'
DOCS_PATH              = File.join(BASE_PATH, DOCS_SEGMENT)
COFFEECHERRIES_PATH    = File.join(BASE_PATH, COFFEECHERRIES_SEGMENT)
TEST_PATH              = File.join(BASE_PATH, TEST_SEGMENT)
TOC_FILESPEC           = File.join(DOCS_PATH, 'index.html')

#================================================================================
def carp!(msg)
  puts(msg)
  exit(1)
end

#================================================================================
def walk_dir_for_files(path_spec, &block)
  Find.find(path_spec) do |dir_entry|
    if FileTest.file?(dir_entry)
      yield dir_entry
    end
  end
end

#================================================================================
def catalog_dirs(recs, path_segment)
  known_paths = Set.new()
  starting_path = File.join(BASE_PATH, path_segment)
  starting_pathname = Pathname.new(starting_path)
  docs_pathname = Pathname.new(DOCS_PATH)
  walk_dir_for_files(starting_path) do |dir_entry|
    if File.extname(dir_entry) == '.coffee'
      relative_path = Pathname.new(File.dirname(dir_entry)).relative_path_from(starting_pathname).to_s
      if not known_paths.include?(relative_path)
        known_paths.add(relative_path)
        coffeescript_path = File.absolute_path(File.join(BASE_PATH, path_segment, relative_path))
        output_path = File.absolute_path(File.join(DOCS_PATH, path_segment, relative_path))
        relative_output_path = Pathname.new(output_path).relative_path_from(docs_pathname).to_s
        recs << [coffeescript_path, output_path, relative_output_path]
      end
    end
  end
end

#================================================================================
def apply_docco(coffeescript_path, output_path)
  FileUtils::Verbose.mkdir_p(output_path)
  docco_command = sprintf('docco --output %s %s/*.coffee', output_path, coffeescript_path)
  printf("%s\n", docco_command)
  system(docco_command)
end

#================================================================================
#==== main
#================================================================================
if __FILE__ == $0

  $stderr.sync = true
  $stdout.sync = true

  # sanity checks

  carp!('docs subtree not found') if (not File.exists?(DOCS_PATH))
  carp!('source subtree not found') if (not File.exists?(COFFEECHERRIES_PATH))
  carp!('test subtree not found') if (not File.exists?(TEST_PATH))

  # prevent orphans

  printf("==== clean out everything within the docs tree\n")
  FileUtils::Verbose.rm_rf(DOCS_PATH)
  FileUtils::Verbose.mkdir(DOCS_PATH)

  # for the project's .coffee source files, identify source and output
  # dir pairs, and apply docco to each pair

  printf("==== apply docco to source files\n")
  coffeecherries_recs = []
  catalog_dirs(coffeecherries_recs, COFFEECHERRIES_SEGMENT)
  coffeecherries_recs.each do |pair|
    coffeescript_path, output_path = pair
    apply_docco(coffeescript_path, output_path)
  end

  # for the project's .coffee test-suite files, identify source and
  # output dir pairs, and apply docco to each pair

  printf("==== apply docco to test files\n")
  test_recs = []
  catalog_dirs(test_recs, TEST_SEGMENT)
  test_recs.each do |pair|
    coffeescript_path, output_path = pair
    apply_docco(coffeescript_path, output_path)
  end

  # generate the table-of-contents index.html file

  printf("==== writing table of contents\n")
  printf("%s\n", TOC_FILESPEC)

  src_html = ""
  coffeecherries_recs.each do |pair|
    Dir.chdir(pair[0]) do |s|
      Dir['*.coffee'].each do |t|
        bn = File.basename(t, '.coffee')
        src_html << sprintf("        <a href='%s/%s.html'>%s/%s</a><br>\n", pair[2], bn, pair[2], t)
      end
    end
  end

  tst_html = ""
  test_recs.each do |pair|
    Dir.chdir(pair[0]) do |s|
      Dir['*.coffee'].each do |t|
        bn = File.basename(t, '.coffee')
        tst_html << sprintf("        <a href='%s/%s.html'>%s/%s</a><br>\n", pair[2], bn, pair[2], t)
      end
    end
  end

  f = File.new(TOC_FILESPEC, "w")
  f.puts(<<EOB
<!DOCTYPE html>
<html>
  <head>
    <meta charset=UTF-8>
    <title>Docco TOC</title>
    <style type="text/css">
      body      { font-family: sans-serif; font-size: 12pt; }
      h1        { font-size: 16pt; font-weight: bold; }
      h2        { font-size: 14pt; font-weight: bold; }
      a:link    { color: #0000ff; text-decoration: none; }
      a:visited { color: #0000ff; text-decoration: none; }
    </style>
  </head>
  <body>
    <h1>Docco TOC</h1>
    <h2>Source</h2>
      <blockquote>
#{src_html}
      </blockquote>
    <h2>Test</h2>
      <blockquote>
#{tst_html}
      </blockquote>
  </body>
</html>
EOB
  )
  f.close()

end
