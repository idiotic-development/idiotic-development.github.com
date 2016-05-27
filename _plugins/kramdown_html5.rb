module Kramdown
  class Converter::Html5 < Converter::Html
    def initialize(root, options)
      super
      @section_stack = []
    end

    def convert_a(el, indent)
      res = inner(el, indent)
      attr = el.attr.dup
      if attr['href'].start_with?('mailto:')
        mail_addr = attr['href'][7..-1]
        attr['href'] = obfuscate('mailto') << ":" << obfuscate(mail_addr)
        res = obfuscate(res) if res == mail_addr
      end

      attr['target'] = "_blank"
      format_as_span_html(el.type, attr, res)
    end

    def convert_codeblock(el, indent)
      attr = el.attr.dup
      lang = extract_code_language!(attr)
      hl_opts = {}
      highlighted_code = highlight_code(el.value, el.options[:lang] || lang, :block, hl_opts)

      if highlighted_code
        add_syntax_highlighter_to_class_attr(attr)
        "#{' '*indent}<figure#{html_attributes(attr)}>#{highlighted_code}#{' '*indent}</figure>\n"
      else
        result = escape_html(el.value)
        result.chomp!
        if el.attr['class'].to_s =~ /\bshow-whitespaces\b/
          result.gsub!(/(?:(^[ \t]+)|([ \t]+$)|([ \t]+))/) do |m|
            suffix = ($1 ? '-l' : ($2 ? '-r' : ''))
            m.scan(/./).map do |c|
              case c
              when "\t" then "<span class=\"ws-tab#{suffix}\">\t</span>"
              when " " then "<span class=\"ws-space#{suffix}\">&#8901;</span>"
              end
            end.join('')
          end
        end
        code_attr = {}
        code_attr['class'] = "language-#{lang}" if lang
        "#{' '*indent}<figure><pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{result}\n</code></pre><figure>\n"
      end
    end

    def footnote_content
      ol = Element.new(:ol)
      ol.attr['start'] = @footnote_start if @footnote_start != 1
      i = 0
      backlink_text = escape_html(@options[:footnote_backlink], :text)
      while i < @footnotes.length
        name, data, _, repeat = *@footnotes[i]
        li = Element.new(:li, nil, {'id' => "fn:#{name}"})
        li.children = Marshal.load(Marshal.dump(data.children))

        if li.children.last.type == :p
          para = li.children.last
          insert_space = true
        else
          li.children << (para = Element.new(:p))
          insert_space = false
        end

        unless @options[:footnote_backlink].empty?
          para.children << Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [insert_space ? ' ' : '', name, backlink_text])
          (1..repeat).each do |index|
            para.children << Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [" ", "#{name}:#{index}", "#{backlink_text}<sup>#{index+1}</sup>"])
          end
        end

        ol.children << Element.new(:raw, convert(li, 4))
        i += 1
      end
      (ol.children.empty? ? '' : format_as_indented_block_html('figure', {:class => "footnotes"}, convert(ol, 2), 0))
    end

    def convert_p(el, indent)
      if el.options[:transparent]
        inner(el, indent)
      # Check if the paragraph only contains an image and treat it as a figure instead.
      elsif !el.children.nil? && el.children.count == 1 && el.children.first.type == :img
        convert_figure(el.children.first, indent)
      else
        format_as_block_html(el.type, el.attr, inner(el, indent), indent)
      end
    end

    def convert_figure(el, indent)
      "#{' '*indent}<figure><img#{html_attributes(el.attr)} />#{(el.attr['title'] ? "<figcaption>#{el.attr['title']}</figcaption>" : "")}</figure>\n"
    end

    def convert_header(el, indent)
        attr = el.attr.dup
        if @options[:auto_ids] && !attr['id']
          attr['id'] = generate_id(el.options[:raw_text])
        end
        @toc << [el.options[:level], attr['id'], el.children] if attr['id'] && in_toc?(el)
        level = output_header_level(el.options[:level])

        if !@section_stack.empty? && @section_stack.last >= level
          result = "</section>"
          @section_stack.pop
        end

        @section_stack.push(level)
        "#{' '*indent}#{result}<section>\n" << format_as_block_html("h#{level}", attr, inner(el, indent), indent)
    end

    def convert_root(el, indent)
      result = inner(el, indent)
      if @footnote_location
        result.sub!(/#{@footnote_location}/, footnote_content.gsub(/\\/, "\\\\\\\\"))
      else
        result << footnote_content
      end

      if !@section_stack.empty?
        result << "</section>" * @section_stack.size
      end

      if @toc_code
        toc_tree = generate_toc_tree(@toc, @toc_code[0], @toc_code[1] || {})
        text = if toc_tree.children.size > 0
                 convert(toc_tree, 0)
               else
                 ''
               end
        result.sub!(/#{@toc_code.last}/, text.gsub(/\\/, "\\\\\\\\"))
      end
      result
    end
  end
end

module Jekyll
  class Converters::Markdown::KramdownHtml5 < Converter
    priority :high

    def initialize(config)
      @config = config
    end


    def matches(ext)
      ext =~ /^\.(md|markdown)$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      Kramdown::Document.new(content, Utils.symbolize_hash_keys(@config['kramdown'])).to_html5
      # Kramdown::Document.new(content).to_html5
    end
  end
end
