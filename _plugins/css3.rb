module CSS3
  class Generator < Jekyll::Generator
    def generate(site)
      site.pages.each{|page| page.content = page.content.gsub(/^([ \t]*)(animation|transform|box-shadow|transition|border-(?:top-|bottom-)?(?:left-|right-)?radius):(.*)$/, '\1\2:\3\1-ms-\2:\3\1-moz-\2:\3\1-webkit-\2:\3')}
    end
  end
end