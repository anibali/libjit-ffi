require 'rubygems'
require 'jeweler'
require 'spec/rake/spectask'
require 'rake/clean'
require 'yard'

require 'pathname'
require 'fileutils'

CLEAN.include("**/*.o")
CLOBBER.include("**/*.so", "pkg", "doc")

#TODO: Jeweler task for each platform

Jeweler::Tasks.new do |s|
  s.name = "libjit-ffi"
  s.summary = "Ruby bindings for libjit using FFI"
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  
  s.add_dependency('ffi')
  
  s.files = %w(LICENSE README.md Rakefile VERSION) + Dir.glob("{lib,spec}/**/*")
  s.require_path = "lib"
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.rdoc_options << '--title' << "#{s.name} #{File.read 'VERSION'}" <<
                    '--main' << 'README.md' << '--line-numbers'
end

Jeweler::GemcutterTasks.new

cur_path = Pathname.new(__FILE__).expand_path.dirname

desc "Compile native extensions for libjit-ffi."
task :compile => ["compile:jitplus"]

namespace :compile do
  desc "Compile jitextra."
  task :jitplus do
    src_path = cur_path.join("ext", "jitextra")
    
    Dir.chdir src_path.realpath do
      sh "rake"
    end
    
    lib_file_src = src_path.join("libjitextra.so").realpath
    lib_file_dest = cur_path.join("lib", "libjitextra.so").to_s
    FileUtils.cp lib_file_src, lib_file_dest
  end
end

task :build => ['compile']

desc "Run all RSpec examples."
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour --format nested'
  t.ruby_opts << '-rrubygems'
end

YARD::Rake::YardocTask.new do |t|
  t.options = [
    '--title', "libjit-ffi #{File.read 'VERSION'}",
    '--readme', 'README.md',
    '-m', 'markdown',
    '--files', 'LICENSE'
  ]
end

