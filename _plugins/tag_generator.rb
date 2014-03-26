# encoding: utf-8
#
# Jekyll tag page generator.
# Modified from http://recursive-design.com/projects/jekyll-plugins/
#
# Copyright (c) 2010 Dave Perrett, http://recursive-design.com/
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# A generator that creates tag pages for jekyll sites.
#
# Included filters :
# - tag_links:      Outputs the list of tags as comma-separated <a> links.
# - date_to_html_string: Outputs the post.date as formatted html, with hooks for CSS styling.
#
# Available _config.yml settings :
# - tag_dir:          The subfolder to build tag pages in (default is 'tags').
# - tag_title_prefix: The string used before the tag name in the page title (default is
#                          'Posts taged with ').

module Jekyll

  # The TagIndex class creates a single tag page for the specified tag.
  class TagIndex < Page

    # Initializes a new TagIndex.
    #
    #  +base+         is the String path to the <source>.
    #  +tag_dir+ is the String path between <source> and the tag folder.
    #  +tag+     is the tag currently being processed.
    def initialize(site, base, tag_dir, tag)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'index.html'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag']    = tag
      # Set the title for this page.
      title_prefix             = site.config['tag_title_prefix'] || 'Posts taged with '
      self.data['title']       = "#{title_prefix}#{tag}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['tag_meta_description_prefix'] || 'Posts taged with '
      self.data['description'] = "#{meta_description_prefix}#{tag}"
    end

  end

  # The TagFeed class creates an Atom feed for the specified tag.
  class TagFeed < Page

    # Initializes a new TagFeed.
    #
    #  +base+         is the String path to the <source>.
    #  +tag_dir+ is the String path between <source> and the tag folder.
    #  +tag+     is the tag currently being processed.
    def initialize(site, base, tag_dir, tag)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'atom.xml'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'tag_feed.xml')
      self.data['tag']    = tag
      # Set the title for this page.
      title_prefix             = site.config['tag_title_prefix'] || 'tag: '
      self.data['title']       = "#{title_prefix}#{tag}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['tag_meta_description_prefix'] || 'tag: '
      self.data['description'] = "#{meta_description_prefix}#{tag}"

      # Set the correct feed URL.
      self.data['feed_url'] = "#{tag_dir}/#{name}"
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    # Creates an instance of TagIndex for each tag page, renders it, and
    # writes the output to a file.
    #
    #  +tag_dir+ is the String path to the tag folder.
    #  +tag+     is the tag currently being processed.
    def write_tag_index(tag_dir, tag)
      index = TagIndex.new(self, self.source, tag_dir, tag)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index

      # Create an Atom-feed for each index.
      feed = TagFeed.new(self, self.source, tag_dir, tag)
      feed.render(self.layouts, site_payload)
      feed.write(self.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << feed
    end

    # Loops through the list of tag pages and processes each one.
    def write_tag_indexes
      if self.layouts.key? 'tag'
        dir = self.config['tag_dir'] || 'tags'
        self.tags.keys.each do |tag|
          self.write_tag_index(File.join(dir, tag.downcase), tag)
        end

      # Throw an exception if the layout couldn't be found.
      else
        raise <<-ERR


===============================================
 Error for tag_generator.rb plugin
-----------------------------------------------
 No 'tag.html' in _layouts/
===============================================

ERR
      end
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the tag pages.
  class Generatetags < Generator
    priority :low

    def generate(site)
      site.write_tag_indexes
    end

  end


  # Adds some extra filters used during the tag creation process.
  module Filters

    # Outputs a list of tags as comma-separated <a> links. This is used
    # to output the tag list for each post on a tag page.
    #
    #  +tags+ is the list of tags to format.
    #
    # Returns string
    #
    def tag_links(tags)
      tags = tags.sort!.map { |c| tag_link c }

      case tags.length
      when 0
        ""
      when 1
        tags[0].to_s
      else
        "#{tags[0...-1].join(', ')}, #{tags[-1]}"
      end
    end

    # Outputs a single tag as an <a> link.
    #
    #  +tag+ is a tag string to format as an <a> link
    #
    # Returns string
    #
    def tag_link(tag)
      "<a href='/tags/#{tag.downcase}/'>#{tag}</a>"
    end
  end

end
