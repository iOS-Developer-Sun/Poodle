require_relative 'Poodle.rb'

PoodleSpec('PoodleLibraryMac', path:'PoodleLibrary', is_library: true, is_macos: true, default_subspec: ['PDLPrivate'])
