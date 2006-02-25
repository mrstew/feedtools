#--
# Copyright (c) 2005 Robert Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

if Object.const_defined?(:FEED_TOOLS_ENV)
  warn("FeedTools may have been loaded improperly.  This may be caused " +
    "by the presence of the RUBYOPT environment variable or by using " +
    "load instead of require.  This can also be caused by missing " +
    "the Iconv library, which is common on Windows.")
end

FEED_TOOLS_ENV = ENV['FEED_TOOLS_ENV'] ||
                 ENV['RAILS_ENV'] ||
                 'development' # :nodoc:

FEED_TOOLS_VERSION = "0.2.23"

FEED_TOOLS_NAMESPACES = {
  "admin" => "http://webns.net/mvcb/",
  "ag" => "http://purl.org/rss/1.0/modules/aggregation/",
  "annotate" => "http://purl.org/rss/1.0/modules/annotate/",
  "atom10" => "http://www.w3.org/2005/Atom",
  "atom03" => "http://purl.org/atom/ns#",
  "atom-blog" => "http://purl.org/atom-blog/ns#",
  "audio" => "http://media.tangent.org/rss/1.0/",
  "bitTorrent" =>"http://www.reallysimplesyndication.com/bitTorrentRssModule",
  "blogChannel" => "http://backend.userland.com/blogChannelModule",
  "blogger" => "http://www.blogger.com/atom/ns#",
  "cc" => "http://web.resource.org/cc/",
  "creativeCommons" => "http://backend.userland.com/creativeCommonsRssModule",
  "co" => "http://purl.org/rss/1.0/modules/company",
  "content" => "http://purl.org/rss/1.0/modules/content/",
  "cp" => "http://my.theinfo.org/changed/1.0/rss/",
  "dc" => "http://purl.org/dc/elements/1.1/",
  "dcterms" => "http://purl.org/dc/terms/",
  "email" => "http://purl.org/rss/1.0/modules/email/",
  "ev" => "http://purl.org/rss/1.0/modules/event/",
  "icbm" => "http://postneo.com/icbm/",
  "image" => "http://purl.org/rss/1.0/modules/image/",
  "feedburner" => "http://rssnamespace.org/feedburner/ext/1.0",
  "foaf" => "http://xmlns.com/foaf/0.1/",
  "fm" => "http://freshmeat.net/rss/fm/",
  "itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",
  "l" => "http://purl.org/rss/1.0/modules/link/",
  "media" => "http://search.yahoo.com/mrss",
  "p" => "http://purl.org/net/rss1.1/payload#",
  "pingback" => "http://madskills.com/public/xml/rss/module/pingback/",
  "prism" => "http://prismstandard.org/namespaces/1.2/basic/",
  "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  "rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
  "ref" => "http://purl.org/rss/1.0/modules/reference/",
  "reqv" => "http://purl.org/rss/1.0/modules/richequiv/",
  "rss09" => "http://my.netscape.com/rdf/simple/0.9/",
  "rss10" => "http://purl.org/rss/1.0/",
  "rss11" => "http://purl.org/net/rss1.1#",
  "search" => "http://purl.org/rss/1.0/modules/search/",
  "slash" => "http://purl.org/rss/1.0/modules/slash/",
  "soap" => "http://schemas.xmlsoap.org/soap/envelope/",
  "ss" => "http://purl.org/rss/1.0/modules/servicestatus/",
  "str" => "http://hacks.benhammersley.com/rss/streaming/",
  "sub" => "http://purl.org/rss/1.0/modules/subscription/",
  "syn" => "http://purl.org/rss/1.0/modules/syndication/",
  "taxo" => "http://purl.org/rss/1.0/modules/taxonomy/",
  "thr" => "http://purl.org/rss/1.0/modules/threading/",
  "ti" => "http://purl.org/rss/1.0/modules/textinput/",
  "trackback" => "http://madskills.com/public/xml/rss/module/trackback/",
  "wfw" => "http://wellformedweb.org/CommentAPI/",
  "wiki" => "http://purl.org/rss/1.0/modules/wiki/",
  "xhtml" => "http://www.w3.org/1999/xhtml",
  "xml" => "http://www.w3.org/XML/1998/namespace"
}

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + "/feed_tools/vendor")

begin
  begin
    require 'iconv'
  rescue LoadError
    warn("The Iconv library does not appear to be installed properly.  " +
      "FeedTools cannot function properly without it.")
    raise
  end

  require 'rubygems'

  require_gem('builder', '>= 1.2.4')

  begin
    require 'tidy'
  rescue LoadError
    # Ignore the error for now.
  end

  require 'feed_tools/vendor/htree'

  require 'net/http'

# TODO: Not used yet, don't load since it'll only be a performance hit
#  require 'net/https'
#  require 'net/ftp'

  require 'rexml/document'

  require 'uri'
  require 'time'
  require 'cgi'
  require 'pp'
  require 'yaml'
  require 'base64'

  require_gem('activesupport', '>= 1.1.1')
  require_gem('activerecord', '>= 1.11.1')

  begin
    require_gem('uuidtools', '>= 0.1.2')
  rescue Gem::LoadError
    raise unless defined? UUID
  end

  require 'feed_tools/feed'
  require 'feed_tools/feed_item'
  require 'feed_tools/feed_structures'
  require 'feed_tools/database_feed_cache'
  
  require 'feed_tools/helpers/html_helper'
  require 'feed_tools/helpers/xml_helper'
  require 'feed_tools/helpers/uri_helper'
rescue LoadError
  # ActiveSupport will very likely mess this up.  So drop a warn so that the
  # programmer can figure it out if things get wierd and unpredictable.
  warn("Unexpected LoadError, it is likely that you don't have one of the " +
    "libraries installed correctly.")
  raise
end

#= feed_tools.rb
#
# FeedTools was designed to be a simple XML feed parser, generator, and translator with a built-in
# caching system.
#
#== Example
#  slashdot_feed = FeedTools::Feed.open('http://www.slashdot.org/index.rss')
#  slashdot_feed.title
#  => "Slashdot"
#  slashdot_feed.description
#  => "News for nerds, stuff that matters"
#  slashdot_feed.link       
#  => "http://slashdot.org/"
#  slashdot_feed.items.first.find_node("slash:hitparade/text()").value
#  => "43,37,28,23,11,3,1"
module FeedTools
  @configurations = {}
  
  def FeedTools.load_configurations
    if @configurations.blank?
      # TODO: Load this from a config file.
      config_hash = {}
      @configurations = {
        :feed_cache => nil,
        :proxy_address => nil,
        :proxy_port => nil,
        :user_agent => "FeedTools/#{FEED_TOOLS_VERSION} " + 
          "+http://www.sporkmonger.com/projects/feedtools/",
        :generator_name => "FeedTools/#{FEED_TOOLS_VERSION}",
        :generator_href => "http://www.sporkmonger.com/projects/feedtools/",
        :tidy_enabled => true,
        :tidy_options => {},
        :sanitization_enabled => true,
        :sanitize_with_nofollow => true,
        :always_strip_wrapper_elements => true,
        :timestamp_estimation_enabled => true,
        :url_normalization_enabled => true,
        :entry_sorting_property => "time",
        :strip_comment_count => false,
        :tab_spaces => 2,
        :max_ttl => 3.days.to_s,
        :output_encoding => "utf-8"
      }.merge(config_hash)
    end
    return @configurations
  end
  
  # Resets configuration to a clean load
  def FeedTools.reset_configurations
    @configurations = nil
    FeedTools.load_configurations
  end
  
  # Returns the configuration hash for FeedTools
  def FeedTools.configurations
    if @configurations.blank?
      FeedTools.load_configurations()
    end
    return @configurations
  end
  
  # Sets the configuration hash for FeedTools
  def FeedTools.configurations=(new_configurations)
    @configurations = new_configurations
  end
  
  # Error raised when a feed cannot be retrieved    
  class FeedAccessError < StandardError
  end
  
  # Returns the current caching mechanism.
  #
  # Objects of this class must accept the following messages:
  #  id
  #  id=
  #  url
  #  url=
  #  title
  #  title=
  #  link
  #  link=
  #  feed_data
  #  feed_data=
  #  feed_data_type
  #  feed_data_type=
  #  etag
  #  etag=
  #  last_modified
  #  last_modified=
  #  save
  #
  # Additionally, the class itself must accept the following messages:
  #  find_by_id
  #  find_by_url
  #  initialize_cache
  #  connected?
  def FeedTools.feed_cache
    return nil if FeedTools.configurations[:feed_cache].blank?
    class_name = FeedTools.configurations[:feed_cache].to_s
    if @feed_cache.nil? || @feed_cache.to_s != class_name
      begin
        cache_class = eval(class_name)
        if cache_class.kind_of?(Class)
          @feed_cache = cache_class
          if @feed_cache.respond_to? :initialize_cache
            @feed_cache.initialize_cache
          end
          return cache_class
        else
          return nil
        end
      rescue
        return nil
      end
    else
      return @feed_cache
    end
  end
  
  # Returns true if FeedTools.feed_cache is not nil and a connection with
  # the cache has been successfully established.  Also returns false if an
  # error is raised while trying to determine the status of the cache.
  def FeedTools.feed_cache_connected?
    begin
      return false if FeedTools.feed_cache.nil?
      return FeedTools.feed_cache.connected?
    rescue
      return false
    end
  end    
  
  # Creates a merged "planet" feed from a set of urls.
  #
  # Options are:
  # * <tt>:multi_threaded</tt> - If set to true, feeds will
  #   be retrieved concurrently.  Not recommended when used
  #   in conjunction with the DatabaseFeedCache as it will
  #   open multiple connections to the database.
  def FeedTools.build_merged_feed(url_array, options = {})
    FeedTools::GenericHelper.validate_options([ :multi_threaded ],
                     options.keys)
    options = { :multi_threaded => false }.merge(options)
    return nil if url_array.nil?
    merged_feed = FeedTools::Feed.new
    retrieved_feeds = []
    if options[:multi_threaded]
      feed_threads = []
      url_array.each do |feed_url|
        feed_threads << Thread.new do
          feed = Feed.open(feed_url)
          retrieved_feeds << feed
        end
      end
      feed_threads.each do |thread|
        thread.join
      end
    else
      url_array.each do |feed_url|
        feed = Feed.open(feed_url)
        retrieved_feeds << feed
      end
    end
    retrieved_feeds.each do |feed|
      merged_feed.entries.concat(
        feed.entries.collect do |entry|
          new_entry = entry.dup
          new_entry.title = "#{feed.title}: #{entry.title}"
          new_entry
        end )
    end
    return merged_feed
  end
end

module REXML # :nodoc:
  class LiberalXPathParser < XPathParser # :nodoc:
  private
    def internal_parse(path_stack, nodeset) # :nodoc:
      return nodeset if nodeset.size == 0 or path_stack.size == 0
      case path_stack.shift
      when :document
        return [ nodeset[0].root.parent ]

      when :qname
        prefix = path_stack.shift.downcase
        name = path_stack.shift.downcase
        n = nodeset.clone
        ns = @namespaces[prefix]
        ns = ns ? ns : ''
        n.delete_if do |node|
          if node.node_type == :element and ns == ''
            ns = node.namespace( prefix )
          end
          !(node.node_type == :element and
            node.name.downcase == name and node.namespace == ns )
        end
        return n

      when :any
        n = nodeset.clone
        n.delete_if { |node| node.node_type != :element }
        return n

      when :self
        # THIS SPACE LEFT INTENTIONALLY BLANK

      when :processing_instruction
        target = path_stack.shift
        n = nodeset.clone
        n.delete_if do |node|
          (node.node_type != :processing_instruction) or 
          ( !target.nil? and ( node.target != target ) )
        end
        return n

      when :text
        n = nodeset.clone
        n.delete_if do |node|
          node.node_type != :text
        end
        return n

      when :comment
        n = nodeset.clone
        n.delete_if do |node|
          node.node_type != :comment
        end
        return n

      when :node
        return nodeset
      
      when :child
        new_nodeset = []
        nt = nil
        for node in nodeset
          nt = node.node_type
          new_nodeset += node.children if nt == :element or nt == :document
        end
        return new_nodeset

      when :literal
        literal = path_stack.shift
        if literal =~ /^\d+(\.\d+)?$/
          return ($1 ? literal.to_f : literal.to_i) 
        end
        return literal
        
      when :attribute
        new_nodeset = []
        case path_stack.shift
        when :qname
          prefix = path_stack.shift
          name = path_stack.shift.downcase
          for element in nodeset
            if element.node_type == :element
              for attribute_name in element.attributes.keys
                if attribute_name.downcase == name
                  attrib = element.attribute( attribute_name,
                    @namespaces[prefix] )
                  new_nodeset << attrib if attrib
                end
              end
            end
          end
        when :any
          for element in nodeset
            if element.node_type == :element
              new_nodeset += element.attributes.to_a
            end
          end
        end
        return new_nodeset

      when :parent
        return internal_parse( path_stack, nodeset.collect{|n| n.parent}.compact )

      when :ancestor
        new_nodeset = []
        for node in nodeset
          while node.parent
            node = node.parent
            new_nodeset << node unless new_nodeset.include? node
          end
        end
        return new_nodeset

      when :ancestor_or_self
        new_nodeset = []
        for node in nodeset
          if node.node_type == :element
            new_nodeset << node
            while ( node.parent )
              node = node.parent
              new_nodeset << node unless new_nodeset.include? node
            end
          end
        end
        return new_nodeset

      when :predicate
        predicate = path_stack.shift
        new_nodeset = []
        Functions::size = nodeset.size
        nodeset.size.times do |index|
          node = nodeset[index]
          Functions::node = node
          Functions::index = index+1
          result = Predicate( predicate, node )
          if result.kind_of? Numeric
            new_nodeset << node if result == (index+1)
          elsif result.instance_of? Array
            new_nodeset << node if result.size > 0
          else
            new_nodeset << node if result
          end
        end
        return new_nodeset

      when :descendant_or_self
        rv = descendant_or_self( path_stack, nodeset )
        path_stack.clear
        return rv

      when :descendant
        results = []
        nt = nil
        for node in nodeset
          nt = node.node_type
          if nt == :element or nt == :document
            results += internal_parse(
              path_stack.clone.unshift( :descendant_or_self ),
              node.children )
          end
        end
        return results

      when :following_sibling
        results = []
        for node in nodeset
          all_siblings = node.parent.children
          current_index = all_siblings.index( node )
          following_siblings = all_siblings[ current_index+1 .. -1 ]
          results += internal_parse( path_stack.clone, following_siblings )
        end
        return results

      when :preceding_sibling
        results = []
        for node in nodeset
          all_siblings = node.parent.children
          current_index = all_siblings.index( node )
          preceding_siblings = all_siblings[ 0 .. current_index-1 ]
          results += internal_parse( path_stack.clone, preceding_siblings )
        end
        return results

      when :preceding
        new_nodeset = []
        for node in nodeset
          new_nodeset += preceding( node )
        end
        return new_nodeset

      when :following
        new_nodeset = []
        for node in nodeset
          new_nodeset += following( node )
        end
        return new_nodeset

      when :namespace
        new_set = []
        for node in nodeset
          if node.node_type == :element or node.node_type == :attribute
            new_nodeset << node.namespace
          end
        end
        return new_nodeset

      when :variable
        var_name = path_stack.shift
        return @variables[ var_name ]

      end
      nodeset
    end
  end
  
  class XPath # :nodoc:
    def self.liberal_match(element, path=nil, namespaces={},
        variables={}) # :nodoc:
			parser = LiberalXPathParser.new
			parser.namespaces = namespaces
			parser.variables = variables
			path = "*" unless path
			element = [element] unless element.kind_of? Array
			parser.parse(path, element)
    end

    def self.liberal_first(element, path=nil, namespaces={},
        variables={}) # :nodoc:
      parser = LiberalXPathParser.new
      parser.namespaces = namespaces
      parser.variables = variables
      path = "*" unless path
      element = [element] unless element.kind_of? Array
      parser.parse(path, element)[0]
    end

    def self.liberal_each(element, path=nil, namespaces={},
        variables={}, &block) # :nodoc:
			parser = LiberalXPathParser.new
			parser.namespaces = namespaces
			parser.variables = variables
			path = "*" unless path
			element = [element] unless element.kind_of? Array
			parser.parse(path, element).each( &block )
    end
  end
  
  class Element # :nodoc:
    unless REXML::Element.public_instance_methods.include? :inner_xml
      def inner_xml # :nodoc:
        result = ""
        self.each_child do |child|
          if child.kind_of? REXML::Comment
            result << "<!--" + child.to_s + "-->"
          else
            result << child.to_s
          end
        end
        return result.strip
      end
    else
      warn("inner_xml method already exists.")
    end
    
    unless REXML::Element.public_instance_methods.include? :base_uri
      def base_uri # :nodoc:
        begin
          base_attribute = attribute('xml:base')
          if parent == nil || parent.kind_of?(REXML::Document)
            return nil if base_attribute == nil
            return base_attribute.value
          end
          if base_attribute != nil && parent == nil
            return base_attribute.value
          elsif parent != nil && base_attribute == nil
            return parent.base_uri
          elsif parent != nil && base_attribute != nil
            uri = URI.parse(parent.base_uri)
            return (uri + base_attribute.value).to_s
          end
          return nil
        rescue
          return nil
        end
      end
    else
      warn("base_uri method already exists.")
    end
  end
end

begin
  unless FeedTools.feed_cache.nil?
    FeedTools.feed_cache.initialize_cache
  end
rescue
end