libs =
  [ 'rubygems'       ,
    'active_record',
    'wirble'         , # IRB tools, tricks, and techniques (requires 'pp', 'irb/completion' and 'rubygems')
    'pp'             , # Pretty Print method
    'ap'             , # Awesome Print (gem install awesome_print)
    'irb/completion' , # Tab Completion
    'map_by_method'  , # Dr Nic's gems
    'what_methods'   , # Dr Nic's gems
    'hirb'           ] # Pretty tables

libs.each do |lib|
  begin
    require lib
  rescue LoadError => err
    $stderr.puts "Couldn't load #{lib}: #{err}"
  end
end


ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => 'db\development.sqlite3')

# Loaded when we fire up the Rails console
# among other things I put the current environment in the prompt

if ENV['RAILS_ENV']
  rails_env = ENV['RAILS_ENV']
  rails_root = File.basename(Dir.pwd)
  prompt = "#{rails_root}[#{rails_env.sub('production', 'prod').sub('development', 'dev')}]"
  IRB.conf[:PROMPT] ||= {}
  
  IRB.conf[:PROMPT][:RAILS] = {
    :PROMPT_I => "#{prompt}>> ",
    :PROMPT_S => "#{prompt}* ",
    :PROMPT_C => "#{prompt}? ",
    :RETURN   => "=> %s\n" 
  }
  
  IRB.conf[:PROMPT_MODE] = :RAILS
  
  #Redirect log to STDOUT, which means the console itself
  IRB.conf[:IRB_RC] = Proc.new do
    logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = logger
    ActiveResource::Base.logger = logger
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end
  
  ### RAILS SPECIFIC HELPER METHODS
  # TODO: DRY this out
  def log_ar_to (stream)
    ActiveRecord::Base.logger = expand_logger stream
    reload!
  end

  def log_ac_to (stream)
    logger = expand_logger stream
    ActionController::Base.logger = expand_logger stream
    reload!
  end
    
  def expand_log_file(name)
    "log/#{name.to_s}.log"
  end
  
  def expand_logger(name)
    if name.is_a? Symbol
      logger = expand_log_file name
    else
      logger = name
    end
    Logger.new logger
  end
end

IRB_START_TIME = Time.now

# Prompt behavior
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

#########################


%w{init colorize}.each { |str| Wirble.send(str) }

colors = Wirble::Colorize.colors.merge({  :comma => :red,    })
Wirble::Colorize.colors = colors

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"
#IRB.conf[:HISTORY_FILE] = "d:/gena/ror/hi"

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE



begin # ANSI codes
  ANSI_BLACK    = "\033[0;30m"
  ANSI_GRAY     = "\033[1;30m"
  ANSI_LGRAY    = "\033[0;37m"
  ANSI_WHITE    = "\033[1;37m"
  ANSI_RED      = "\033[0;31m"
  ANSI_LRED     = "\033[1;31m"
  ANSI_GREEN    = "\033[0;32m"
  ANSI_LGREEN   = "\033[1;32m"
  ANSI_BROWN    = "\033[0;33m"
  ANSI_YELLOW   = "\033[1;33m"
  ANSI_BLUE     = "\033[0;34m"
  ANSI_LBLUE    = "\033[1;34m"
  ANSI_PURPLE   = "\033[0;35m"
  ANSI_LPURPLE  = "\033[1;35m"
  ANSI_CYAN     = "\033[0;36m"
  ANSI_LCYAN    = "\033[1;36m"

  ANSI_BACKBLACK  = "\033[40m"
  ANSI_BACKRED    = "\033[41m"
  ANSI_BACKGREEN  = "\033[42m"
  ANSI_BACKYELLOW = "\033[43m"
  ANSI_BACKBLUE   = "\033[44m"
  ANSI_BACKPURPLE = "\033[45m"
  ANSI_BACKCYAN   = "\033[46m"
  ANSI_BACKGRAY   = "\033[47m"

  ANSI_RESET      = "\033[0m"
  ANSI_BOLD       = "\033[1m"
  ANSI_UNDERSCORE = "\033[4m"
  ANSI_BLINK      = "\033[5m"
  ANSI_REVERSE    = "\033[7m"
  ANSI_CONCEALED  = "\033[8m"

  XTERM_SET_TITLE   = "\033]2;"
  XTERM_END         = "\007"
  ITERM_SET_TAB     = "\033]1;"
  ITERM_END         = "\007"
  SCREEN_SET_STATUS = "\033]0;"
  SCREEN_END        = "\007"
end


class Object
  def pm(*options) # Print methods
    methods = self.methods
    methods -= Object.methods unless options.include? :more
    filter = options.select {|opt| opt.kind_of? Regexp}.first
    methods = methods.select {|name| name =~ filter} if filter

    data = methods.sort.collect do |name|
      method = self.method(name)
      if method.arity == 0
        args = "()"
      elsif method.arity > 0
        n = method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")})"
      elsif method.arity < 0
        n = -method.arity
        args = "(#{(1..n).collect {|i| "arg#{i}"}.join(", ")}, ...)"
      end
      klass = $1 if method.inspect =~ /Method: (.*?)#/
      [name, args, klass]
    end
    max_name = data.collect {|item| item[0].size}.max
    max_args = data.collect {|item| item[1].size}.max
    data.each do |item| 
      print "#{ANSI_LGRAY}#{item[0].to_s.rjust(max_name)}#{ANSI_RESET}"
      print "#{ANSI_BLUE}#{item[1].to_s.ljust(max_args)}#{ANSI_RESET}"
      print "#{ANSI_RED}#{item[2]}#{ANSI_RESET}\n"
    end
    data.size
  end
end
#########################
### IRb HELPER METHODS

#clear the screen
def clear
  system('cls')
end
alias :cl :clear

#ruby documentation right on the console
# ie. ri Array#each
def ri(*names)
  system(%{ri #{names.map {|name| name.to_s}.join(" ")}})
end

### CORE EXTENSIONS
class Object
  #methods defined in the parent class of the object
  def local_methods
    (methods - Object.instance_methods).sort
  end
  
  #copy to pasteboard
  #pboard = general | ruler | find | font
  def to_pboard(pboard=:general)
    %x[printf %s "#{self.to_s}" | pbcopy -pboard #{pboard.to_s}]
    paste pboard
  end
  alias :to_pb :to_pboard

  #paste from given pasteboard
  #pboard = general | ruler | find | font
  def paste(pboard=:general)
    %x[pbpaste -pboard #{pboard.to_s}].chomp
  end
  
  def to_find
    self.to_pb :find
  end  

  def eigenclass
    class << self; self; end
  end

  def ql
    %x[qlmanage -p #{self.to_s} >& /dev/null  ]
  end
  #------------------------------------------------------------
  def introspect(obj = self)
    klass      = obj.class
    heirarchy  = klass.name
    superklass = klass.superclass
    modules    = klass.ancestors.to_set.delete(klass)
    while not superklass.nil?
      modules.delete(superklass)
      heirarchy += " < " + superklass.name
      superklass = superklass.superclass
    end
    puts "type:\n  " + heirarchy + "\n"
    puts "including modules:\n  " + modules.to_a.join(", ") + "\n"
  end


  #------------------------------------------------------------


end

class Class
  public :include
  
  def class_methods
    (methods - Class.instance_methods - Object.methods).sort
  end
  alias :cm :class_methods
  
  #Returns an array of methods defined in the class, class methods and instance methods
  def defined_methods
    methods = {}
    
    methods[:instance] = new.local_methods
    methods[:class] = class_methods
    
    methods
  end
  alias :dm :defined_methods
  
  def metaclass
    eigenclass
  end
end

def tables
  ActiveRecord::Base.connection.tables.sort!
end

def col(table)
  ActiveRecord::Base.connection.columns(table).map(&:name).sort!
end

def models
  tables.select{|t| t != "schema_migrations"}.map{|t| t.underscore.singularize.camelize.to_sym}
end

Hirb.enable

### USEFUL ALIASES
alias q exit

system("ruby -v")

