module RainbowCloth
  class Document
    def to_greencloth
      GreenCloth.process!(doc)
    end
  end

  class GreenCloth < Textile

    # inline elements
    rule_for(:a) {|e|
      "[%s%s%s]" % process_links_and_anchors(e)
    }

    def process_links_and_anchors(e)
      inner, name, href = e.inner_html, e.get_attribute("name"), e.get_attribute("href")

      # is an anchor? and cannot be child of any h1..h6
      if name && !e.parent.name.match(/^h1|2|3|4|5|6$/)
        fill_with = inner == name || inner == name.gsub(/-/,"\s") ? ["# ", "#{inner}", " #"] : ["# #{inner}", " -> ", "#{name} #"]
      # is a link to an anchor?
      elsif href && href =~ /^\/#/
        fill_with = ["\"#{inner}\"", ":", "#{href}"]
      elsif href && href =~ /^#/
        fill_with = ["#{inner}", " -> ", "#{href}"]
      # it is an external link?
      elsif href && href =~ /^(https?|s?ftp):\/\//
        return href.gsub(/^(https?|s?ftp):\/\//, "") == inner ? ["#{href}", "", ""] : ["#{inner}", " -> ", "#{href}"]
      # links starting without /
      elsif href && href =~ /^[^\/]/
        return ["", "#{e.inner_text}", ""]
      # link with 3 more /
      elsif href && href.count("/") >= 3
        fill_with = ["#{inner}", " -> ", "#{href}"]
      # wiki page with index
      elsif href && href =~ /(?:\/page\/\+)[0-9]+$/
        fill_with = ["#{inner}", " -> ", "+#{href.gsub(/\+[0-9]+$/)}"]
      # pages or group pages
      else
        context_name, page_name = href.split("/")[1..2]
        page_name = context_name if page_name.nil?
        wiki_page_name = page_name.gsub(/[a-z-]*[^\/]$/m) {|m| m.tr('-',' ')}

        # simple page
        if context_name == "page"
          return ["#{inner}", "", ""] if wiki_page_name == inner
          return ["#{inner}", " -> ", "#{wiki_page_name}"]
        end
        # group page
        if context_name != page_name
          return ["#{context_name}", " / ", "#{wiki_page_name}"] if wiki_page_name == inner
          return ["#{inner}", " -> ", "#{wiki_page_name}"] if context_name == "page"
          return ["#{inner}", " -> ", "#{context_name} / #{wiki_page_name}"]
        end 
        if inner == page_name || inner == wiki_page_name || inner == wiki_page_name.gsub(/\s/,"-")
          return ["#{wiki_page_name}", "", ""]
        end
        # fall back
        return ["#{inner}", " -> ", "#{href}"]
      end
      fill_with
    end
  end
end
