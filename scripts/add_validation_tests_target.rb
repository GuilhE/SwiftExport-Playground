require 'xcodeproj'

project_path = File.expand_path('../iosApp/SwiftExport.xcodeproj', __dir__)
proj = Xcodeproj::Project.open(project_path)

app_target = proj.targets.find { |t| t.name == 'SwiftExport' }
raise 'app target not found' unless app_target

if proj.targets.any? { |t| t.name == 'SwiftExportValidationTests' }
  puts 'Target already exists, skipping creation.'
  exit 0
end

test_target = proj.new_target(:unit_test_bundle, 'SwiftExportValidationTests', :ios, '26.0', nil, :swift)

test_target.build_configuration_list.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.swiftexport.validationtests'
  config.build_settings['SWIFT_VERSION'] = '6.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = '$(inherited)'
  config.build_settings.delete('TEST_HOST')
  config.build_settings.delete('BUNDLE_LOADER')
end

# Mirror the Kotlin embed step so this target can resolve KotlinRuntime/KotlinToSwift on its own.
app_script_phase = app_target.build_phases.find { |bp| bp.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) }
script_phase = test_target.new_shell_script_build_phase('Compile Kotlin Framework')
script_phase.shell_script = app_script_phase.shell_script
script_phase.always_out_of_date = app_script_phase.always_out_of_date
test_target.build_phases.delete(script_phase)
test_target.build_phases.unshift(script_phase)

# Add iosAppTests/*.swift as a regular group + Sources build phase entries.
tests_group = proj.main_group.new_group('iosAppTests', 'iosAppTests')
Dir.glob(File.expand_path('../iosApp/iosAppTests/*.swift', __dir__)).sort.each do |path|
  file_ref = tests_group.new_reference(File.basename(path))
  test_target.add_file_references([file_ref])
end

proj.save
puts "Created target 'SwiftExportValidationTests' with #{Dir.glob(File.expand_path('../iosApp/iosAppTests/*.swift', __dir__)).size} test file(s)."
