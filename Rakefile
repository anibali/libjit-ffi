require 'rubygems'
require 'jeweler'
require 'spec/rake/spectask'
require 'rake/clean'
require 'yard'

require 'pathname'
require 'fileutils'

CLOBBER.include("pkg", "doc")

#TODO: Task for each platform

Jeweler::Tasks.new do |s|
  s.name = 'libjit-ffi'
  s.summary = 'Ruby bindings for libjit using FFI'
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  s.homepage = 'http://github.com/dismaldenizen/libjit-ffi'
  
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

desc "Run all RSpec examples."
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour --format progress'
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

