module LXC
  class Configuration
    include LXC::ConfigurationOptions

    attr_reader :content

    # Initialize a new LXC::Configuration instance
    # @param [data] string or hash data (optional)
    def initialize(data=nil)
      if data.kind_of?(String)
        @content = parse(data)
      end
    end

    # Load an existing LXC container configuration from file
    # @param [path] path to configuration
    # @return [LXC::Configuration]
    def self.load_file(path)
      fullpath = File.expand_path(path)

      if !File.exists?(fullpath)
        raise ArgumentError, "File '#{path}' does not exist."
      end

      LXC::Configuration.new(File.read(fullpath))
    end

    # Get all configuration attributes
    # @return [Array]
    def attributes
      @content.keys
    end

    # Get attribute value
    # @param [key] attribute name
    # @return [String] configuration attribute value
    def [](key)
      @content[key.to_s]
    end

    def method_missing(key)
      @content[key.to_s]
    end

    # Save configuration into file
    # @param [path] path to output file
    def save_to_file(path)
      fullpath = File.expand_path(path)
      lines = []

      @content.each_pair do |key,value|
        k = "lxc.#{key.gsub('_', '.')}"

        if value.kind_of?(Array)
          lines << value.map { |v| "#{k} = #{v}" }
        else
          lines << "#{k} = #{value}"
        end
      end

      File.open(path, "w") do |f|
        f.write(lines.flatten.join("\n"))
      end
    end

    private

    def parse(data)
      hash = {}
      lines = data.split("\n").map(&:strip).select { |l| !l.empty? && l[0,1] != "#" }

      lines.each do |l|
        key,value = l.split("=").map(&:strip)

        if !valid_option?(key)
          raise ConfigurationError, "Invalid config attribute: #{key}."
        end

        key.gsub!(/^lxc\./, '').gsub!(".", "_")
        
        hash[key] = [] if !hash.key?(key)
        hash[key] << value
      end

      hash.each_pair do |k, v| 
        hash[k] = v.first if v.size == 1
      end

      hash
    end
  end
end