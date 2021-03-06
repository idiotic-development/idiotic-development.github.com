# This plugin allows you to define blocks of markdown in any file.
#
# {% markdown %}
# [Stack Overflow](http://www.stackoverflow.com)
# {% endmarkdown %}
#

module Jekyll
  class MarkdownBlock < Liquid::Block
    def initialize(tag_name, text, tokens)
      super
    end
    require "kramdown"
    def render(context)
      content = super
      # Kramdown::Document.new(content, Jekyll::Utils.symbolize_hash_keys(@config['kramdown'])).to_html5
      Kramdown::Document.new(content).to_html5
    end
  end
end
Liquid::Template.register_tag('markdown', Jekyll::MarkdownBlock)
