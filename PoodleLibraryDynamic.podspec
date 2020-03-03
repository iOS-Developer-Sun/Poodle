$LOAD_PATH << '.'
require 'Poodle.rb'

PoodleDynamicSpec('PoodleLibraryDynamic', path: 'PoodleLibrary', is_library: true, base_pod_name: 'PoodleLibrary')
