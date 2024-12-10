# Load constants from YAML files in config/constants directory
constants_dir = "config/constants"
if Dir.exist?(constants_dir)
  constant_hash = Dir.glob(File.join(constants_dir, "*.yml")).reduce({}) do |hash, file_path|
    hash.merge(YAML.load_file(file_path))
  end
  APP_CONSTANTS = JSON.parse(constant_hash.to_json, object_class: OpenStruct)
else
  Rails.logger.error "Constants directory '#{constants_dir}' does not exist"
end
