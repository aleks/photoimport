require "option_parser"
require "file_utils"

source_path = ""
target_path = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: photoimport [arguments]"
  parser.on("-s SOURCE", "--source=SOURCE", "Source directory") { |source| source_path = source}
  parser.on("-t TARGET", "--target=TARGET", "Target directory") { |target| target_path = target}
end

files  = [] of String
source = Dir.new(source_path)
target = Dir.new(target_path)

source.each_child do |item|
  child_path = [source_path, item].join('/')

  if Dir.exists?(child_path)
    Dir.new(child_path).each_child do |child|
      files << [child_path, child].join('/')
    end
  end
end

files.each do |file_path|
  # create directories in target path
  file_mtime= File.stat(file_path).mtime.to_s.scan(/\d{4}\-\d{2}\-\d{2}/).first[0].to_s.split('-')
  file_target_directory = [target_path, file_mtime].flatten.join('/')
  Dir.mkdir_p(file_target_directory)

  # copy files from source to target directory
  FileUtils.cp(file_path, file_target_directory)
end
