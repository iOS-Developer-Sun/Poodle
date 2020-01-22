$LOAD_PATH << '.'
require 'PoodleLibrary.rb'

PoodleLibraryDynamicSpec('PoodleDynamic', path: 'Poodle', base_pod_name: 'Poodle')
