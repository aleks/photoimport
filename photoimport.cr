require "option_parser"
require "file_utils"
require "progress_bar.cr/progress_bar"

class Photoimport

  def initialize
    @source_path = ""
    @target_path = ""
    @verbose = false
    @files  = [] of String
  end

  def run
    parse_options
    puts "Missing SOURCE argument" if @source_path == ""
    puts "Missing TARGET argument" if @target_path == ""
    #exit

    find_source_files
    find_target_directory
    copy_files_to_target
  end

  private def parse_options
    OptionParser.parse! do |parser|
      parser.banner = "Usage: photoimport [arguments]"
      parser.on("-s SOURCE", "--source=SOURCE", "Source directory") { |source| @source_path = source }
      parser.on("-t TARGET", "--target=TARGET", "Target directory") { |target| @target_path = target }
      parser.on("-v", "--verbose", "Show info") { |target| @verbose = true }
    end
  end

  private def find_source_files
    if Dir.exists?(@source_path)
      puts "Source path: #{@source_path}" if @verbose

      source = Dir.new(@source_path)

      source.each_child do |item|
        child_path = [@source_path, item].join('/')

        if Dir.exists?(child_path)
          Dir.new(child_path).each_child do |child|
            @files << [child_path, child].join('/')
          end
        end
      end
    else
      puts "Can't find SOURCE directory"
    end
  end

  private def find_target_directory
    puts "Can't find TARGET directory" unless Dir.exists?(@target_path)
  end

  private def copy_files_to_target
    pb = ProgressBar.new(ticks: @files.size, chars: ["▒", "█"], show_percentage: true, completion_message: "Done!")

    pb.with_progress do
      pb.init

      @files.each do |file_path|
        # create directories in target path
        file_mtime = File.stat(file_path).mtime.to_s.scan(/\d{4}\-\d{2}\-\d{2}/).first[0].to_s.split('-')
        file_target_directory = [@target_path, file_mtime].flatten.join('/')
        Dir.mkdir_p(file_target_directory)

        # copy files from source to target directory
        if FileUtils.cp(file_path, file_target_directory)
          #puts "Copied: #{file_path} to #{file_target_directory}" if @verbose
          pb.tick
        end
      end
    end
  end

end

Photoimport.new.run
