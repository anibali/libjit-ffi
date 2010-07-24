# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{libjit-ffi}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aiden Nibali"]
  s.date = %q{2010-07-24}
  s.description = %q{Ruby bindings for libjit using FFI}
  s.email = %q{dismal.denizen@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "lib/libjit.rb",
     "lib/libjit/constant.rb",
     "lib/libjit/context.rb",
     "lib/libjit/control_structures.rb",
     "lib/libjit/errors.rb",
     "lib/libjit/function.rb",
     "lib/libjit/label.rb",
     "lib/libjit/type.rb",
     "lib/libjit/value.rb",
     "lib/libjitextra.so",
     "spec/arithmetic_spec.rb",
     "spec/bitwise_spec.rb",
     "spec/bool_spec.rb",
     "spec/call_other_spec.rb",
     "spec/comparison_spec.rb",
     "spec/constant_spec.rb",
     "spec/context_spec.rb",
     "spec/if_spec.rb",
     "spec/libc_spec.rb",
     "spec/pointer_spec.rb",
     "spec/pointer_type_spec.rb",
     "spec/primitive_type_spec.rb",
     "spec/shared/type_examples.rb",
     "spec/spec_helper.rb",
     "spec/struct_spec.rb",
     "spec/struct_type_spec.rb",
     "spec/type_spec.rb",
     "spec/value_spec.rb",
     "spec/void_type_spec.rb",
     "spec/while_spec.rb"
  ]
  s.homepage = %q{http://github.com/dismaldenizen/libjit-ffi}
  s.rdoc_options = ["--charset=UTF-8", "--title", "libjit-ffi 0.0.0\n", "--main", "README.md", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby bindings for libjit using FFI}
  s.test_files = [
    "spec/value_spec.rb",
     "spec/context_spec.rb",
     "spec/libc_spec.rb",
     "spec/void_type_spec.rb",
     "spec/pointer_type_spec.rb",
     "spec/struct_spec.rb",
     "spec/bitwise_spec.rb",
     "spec/if_spec.rb",
     "spec/type_spec.rb",
     "spec/while_spec.rb",
     "spec/constant_spec.rb",
     "spec/pointer_spec.rb",
     "spec/spec_helper.rb",
     "spec/call_other_spec.rb",
     "spec/struct_type_spec.rb",
     "spec/arithmetic_spec.rb",
     "spec/bool_spec.rb",
     "spec/primitive_type_spec.rb",
     "spec/shared/type_examples.rb",
     "spec/comparison_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 0"])
    else
      s.add_dependency(%q<ffi>, [">= 0"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 0"])
  end
end

