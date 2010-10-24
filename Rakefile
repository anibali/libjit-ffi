require 'rubygems'
require 'burke'

Burke.setup do
  name      'libjit-ffi'
  summary   'Ruby bindings for libjit using FFI'
  author    'Aiden Nibali'
  email     'dismal.denizen@gmail.com'
  homepage  'http://github.com/dismaldenizen/libjit-ffi'
  
  clean     %w[.yardoc]
  clobber   %w[pkg doc html coverage]
  
  rspec.rcov.failure_threshold = 89
  
  gems do
    add_platform 'ruby'
    
    [ %w[x86-linux libjit-0.1.2-x86-linux.so libjit.so],
      %w[x86_64-linux libjit-0.1.2-x86_64-linux.so libjit.so],
      %w[x86-mingw32 libjit-0.1.2-x86-mingw32.dll libjit.dll],
    ].each do |plaf, lib_src, lib_dest|
      lib_src = File.join 'native', lib_src
      lib_dest = File.join 'lib', 'libjit', lib_dest
      
      add_platform plaf do
        before_build do |s|
          cp lib_src, lib_dest
          s.files << lib_dest
        end

        after_build do
          rm lib_dest
        end
      end
    end
  end
end

