$LOAD_PATH << '.'
require 'Poodle.rb'

PoodleSpec('PoodleLibrary', is_library: true, default_subspec: ['PDLPrivate'])
