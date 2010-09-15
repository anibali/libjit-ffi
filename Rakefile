require 'rubygems'
require 'burke'

Burke.enable_all

Burke.setup do |s|
  s.name = 'libjit-ffi'
  s.summary = 'Ruby bindings for libjit using FFI'
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  s.homepage = 'http://github.com/dismaldenizen/libjit-ffi'
  
  s.dependencies do |d|
    d.ffi = '~> 0.6.3'
  end
  
  s.has_rdoc = true
  
  s.clean = %w[.yardoc]
  s.clobber = %w[pkg doc html coverage]
  
  s.rspec.ruby_opts = '-rubygems'
  s.rspec.rcov.threshold = 91.75
  
  s.gems do |g|
    g.platform 'ruby'
    
    [ %w[x86-linux libjit-0.1.2-x86-linux.so libjit.so],
      %w[x86_64-linux libjit-0.1.2-x86_64-linux.so libjit.so],
      %w[x86-mingw32 libjit-0.1.2-x86-mingw32.dll libjit.dll],
    ].each do |plaf, lib_src, lib_dest|
      lib_src = File.join 'native', lib_src
      lib_dest = File.join 'lib', 'libjit', lib_dest
      
      g.platform plaf do |p|
        p.before do |s|
          cp lib_src, lib_dest
          s.files << lib_dest
        end

        p.after do
          rm lib_dest
        end
      end
    end
  end
end

