require 'shellwords'

module Jekyll
  class StylusConverter < Converter
    safe true

    def matches(ext)
      ext =~ /\.styl/i
    end

    def output_ext(ext)
      '.css'
    end

    def convert(content)
      begin
        command = Shellwords.escape content
        `echo #{command} | stylus`
      rescue => e
        puts "Stylus Exception: #{e.message}"
      end
    end
  end

  class StylusBlock < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      content = super
      begin
        command = Shellwords.escape content
        `echo #{command} | stylus -p`
      rescue => e
        puts "Stylus Exception: #{e.message}"
      end
    end
  end
end
Liquid::Template.register_tag('stylus', Jekyll::StylusBlock)
