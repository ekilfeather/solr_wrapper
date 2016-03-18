module SolrWrapper
  class Configuration
    attr_reader :options

    def initialize(options)
      @options = read_config(options[:config], options[:verbose])
             .merge options
    end

    def solr_xml
      options[:solr_xml]
    end

    def extra_lib_dir
      options[:extra_lib_dir]
    end

    def validate
      options[:validate]
    end

    def ignore_md5sum
      options[:ignore_md5sum]
    end

    def md5sum
      options[:md5sum]
    end

    def url
      options[:url]
    end

    def port
      # Check if the port option has been explicitly set to nil.
      # this means to start solr wrapper on a random open port
      return nil if options.key?(:port) && !options[:port]
      options[:port] || SolrWrapper.default_instance_options[:port]
    end

    def download_path
      options[:download_path]
    end

    def download_dir
      options[:download_dir]
    end

    def solr_options
      options.fetch(:solr_options, {})
    end

    def env
      options.fetch(:env, {})
    end

    def instance_dir
      options[:instance_dir]
    end

    def version
      @version ||= options.fetch(:version, SolrWrapper.default_instance_options[:version])
    end

    def mirror_url
      "http://www.apache.org/dyn/closer.lua/lucene/solr/#{version}/solr-#{version}.zip?asjson=true"
    end

    def cloud
      options[:cloud]
    end

    def verbose?
      !!options.fetch(:verbose, false)
    end

    def version_file
      options[:version_file]
    end

    private

      def read_config(config_file, verbose)
        default_configuration_paths.each do |p|
          path = File.expand_path(p)
          config_file ||= path if File.exist? path
        end

        unless config_file
          $stdout.puts "No config specified" if verbose
          return {}
        end

        $stdout.puts "Loading configuration from #{config_file}" if verbose
        config = YAML.load(ERB.new(IO.read(config_file)).result(binding))
        unless config
          $stderr.puts "Unable to parse config #{config_file}" if verbose
          return {}
        end
        config.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.to_s }
      end

      def default_configuration_paths
        ['.solr_wrapper', '~/.solr_wrapper']
      end
  end
end