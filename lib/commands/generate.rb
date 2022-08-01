module Commands
  class Generate
    attr_reader :path_pages, :path_gherkin, :path_steps

    @@buffer_dirname = { page:'', step:'', gherkin:'', root_project_path:'' }
    @@buffer_dir_filename = []

    def start(op)
      define_project_root
      normalize_name_files(op[1])

      case op[0]
      when 'a'
        create_all([@path_gherkin, @path_pages, @path_steps], op[1])
      when 'p'
        create_file_dir(@path_pages, op[1])
        create_page(@@buffer_dir_filename[0], @file)
      when 's'
        create_file_dir(@path_steps, op[1])
        create_steps(@@buffer_dir_filename[0], @file)
      when 'g'
        create_file_dir(@path_gherkin, op[1])
        create_gherkin(@@buffer_dir_filename[0], @file)
      end
    end
    
    private

    def create_all(paths, op)
      paths.each { |path| create_file_dir(path, op) }
      create_gherkin(@@buffer_dir_filename[0], @file)
      create_page(@@buffer_dir_filename[1], @file)
      create_steps(@@buffer_dir_filename[2], @file)
    end

    # Set your project name here.
    def define_project_root
      @root_project_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../demo/features/'))
      @@buffer_dirname[:root_project_path] << @root_project_path

      check_dir(@root_project_path)
      set_paths(@root_project_path)
    end

    def set_paths(root_project_path)
      @path_gherkin = File.join(root_project_path,'/specs')
      @path_pages = File.join(root_project_path,'/page_objects/pages')
      @path_steps = File.join(root_project_path,'/step_definitions')
      @@buffer_dirname[:gherkin] << @path_gherkin
      @@buffer_dirname[:page] << @path_pages
      @@buffer_dirname[:step] << @path_steps

      @@buffer_dirname.each { |k, v| check_dir(v) }
      # print_paths
    end

    def create_page(path,file)
      File.open "#{path}/#{file}.rb", 'w'
    end
    
    def create_gherkin(path,file)
      File.open "#{path}/#{file}.feature", 'w'
    end
    
    def create_steps(path,file)
      File.open "#{path}/#{file}_steps.rb", 'w'
    end

    def create_file_dir(path,file)
      _folder = File.join("#{path}/",file)
      @@buffer_dir_filename << _folder

      unless File.directory?(_folder)
        FileUtils.mkdir_p(_folder)
        puts "OK! >>> #{_folder}"
      else
        puts "FAIL >>> #{_folder}"
        raise "Create Error"
      end
    end

    # remove name before '/' slash
    # ex: data_page/home
    # => @file = "home"
    def normalize_name_files(path)
      _file = path.match(/[^\/]*$/)
      @file = _file[0]
    end

    # def rgx_path
    #   /[?<=\/]/
    # end

    def check_dir(dir_name)
      unless File.directory? dir_name
        puts "Directory dont exists: #{dir_name}"
        puts "Root project: #{@root_project_path}"
        raise "PROJECT FOLDER ERROR" 
      else
        true
      end
    end

    def print_paths
      @@buffer_dirname.each { |k, v| puts "#{k} >>> [#{v}]" }
    end
  end
end