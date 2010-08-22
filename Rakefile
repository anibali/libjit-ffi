require 'rubygems'
require 'burke'

require 'pathname'
require 'fileutils'

require 'rake/clean'
CLOBBER.include("pkg", "doc", "*.gemspec")

Burke.base_spec do |s|
  s.name = 'libjit-ffi'
  s.version = File.read('VERSION')
  s.summary = 'Ruby bindings for libjit using FFI'
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  s.homepage = 'http://github.com/dismaldenizen/libjit-ffi'
  
  s.add_dependency 'ffi'
  
  s.add_development_dependency 'rubygems'
  s.add_development_dependency 'burke'
  
  s.files = %w[LICENSE README.md Rakefile VERSION] + Dir.glob('{lib,spec}/**/*')
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.rdoc_options << '--title' << "#{s.name} #{File.read 'VERSION'}" <<
                    '--main' << 'README.md' << '--line-numbers'
end

Burke.package_task

%w[x86 x86_64].each do |arch|
  Burke.package_task "#{arch}-linux" do |t|
    t.before do
      verbose true do
        cp "native/libjit-0.1.2-#{arch}-linux.so", 'lib/libjit/libjit.so'
      end
    end

    t.extend_spec do |s|
      s.files += ['lib/libjit/libjit.so']
    end

    t.after do
      verbose true do
        rm 'lib/libjit/libjit.so'
      end
    end
  end
end

Burke.package_task "x86-mingw32" do |t|
  t.before do
    verbose true do
      cp "native/libjit-0.1.2-x86-mingw32.dll", 'lib/libjit/libjit.dll'
    end
  end

  t.extend_spec do |s|
    s.files += ['lib/libjit/libjit.dll']
  end

  t.after do
    verbose true do
      rm 'lib/libjit/libjit.dll'
    end
  end
end

Burke.spec_task 'spec' do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour --format progress'
  t.ruby_opts << '-rubygems'
end

desc "Run specs with rcov"
Burke.spec_task 'spec:rcov' do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour --format progress'
  t.ruby_opts << '-rubygems'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

Burke.rcov_verify_task 'spec:rcov:verify' => 'spec:rcov' do |t|
  t.threshold = 91.58
  t.index_html = 'coverage/index.html'
end

Burke.yard_task do |t|
  t.options = [
    '--title', "libjit-ffi #{Burke.base_spec.version}",
    '--readme', 'README.md',
    '-m', 'markdown',
    '--files', 'LICENSE'
  ]
end

