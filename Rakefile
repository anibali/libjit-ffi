require 'rubygems'
require 'jeweler'
require 'spec/rake/spectask'
require 'rake/clean'
require 'pathname'
require 'fileutils'

CLEAN.include("**/*.o")
CLOBBER.include("**/*.so")

Jeweler::Tasks.new do |s|
  s.name = "libjit-ffi"
  s.summary = "Ruby bindings for libjit using FFI"
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  
  s.add_dependency('ffi')
  
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,spec}/**/*")
  s.require_path = "lib"
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.rdoc_options << '--title' << "#{s.name} #{File.read 'VERSION'}" <<
                    '--main' << 'README' << '--line-numbers'
end

Jeweler::GemcutterTasks.new

cur_path = Pathname.new(__FILE__).expand_path.dirname

desc "Compile native extensions for libjit-ffi."
task :compile => ["compile:jitplus"]

namespace :compile do
  desc "Compile jitplus."
  task :jitplus do
    src_path = cur_path.join("ext", "jitplus")
    
    Dir.chdir src_path.realpath do
      sh "rake"
    end
    
    lib_file_src = src_path.join("libjitplus.so").realpath
    lib_file_dest = cur_path.join("lib", "libjitplus.so").to_s
    FileUtils.cp lib_file_src, lib_file_dest
  end
end

desc "Run all RSpec examples."
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour'
  t.ruby_opts << '-rrubygems'
end

