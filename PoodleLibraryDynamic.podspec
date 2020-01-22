$LOAD_PATH << '.'
require 'PoodleLibrary.rb'

PoodleLibraryDynamicSpec('PoodleLibraryDynamic', path: 'PoodleLibrary', is_library: true, base_pod_name: 'PoodleLibrary')
