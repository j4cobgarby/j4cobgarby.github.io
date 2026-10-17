require "kramdown"

THUMB_FROM = %r{https://nc\.jgarby\.uk/public/p/}
THUMB_TO   = "https://nc.jgarby.uk/pthumb/"

def thumb_url(url)
  url.sub(THUMB_FROM, THUMB_TO)
end

module FigureImages
  def convert_p(el, indent)
    kids = el.children.reject { |c| c.type == :text && c.value.strip.empty? }
    return super unless !kids.empty? && kids.all? { |c| c.type == :img }

    cls = kids.first.attr["class"].to_s.split
    if kids.size == 1 && (cls.include?("left") || cls.include?("right"))
      return figure_html(kids.first)
    end

    html = +"<div class=\"figures\">\n"
    kids.each { |img| html << figure_html(img) }
    html << "</div>\n"
  end

  def figure_html(img)
    attrs = img.attr.dup
    caption = attrs.delete("title")
    cls = attrs.delete("class")
    src = escape_html(attrs["src"].to_s, :attribute)
    attrs["src"] = thumb_url(attrs["src"].to_s)

    if !caption
      caption = ""
    end

    fig_class = cls ? %( class="#{escape_html(cls, :attribute)}") : ""
    html = +"<figure#{fig_class}>\n"
    html << "<a href=\"#{src}\"><img#{html_attributes(attrs)} /></a>\n"
    html << "<figcaption>#{escape_html(caption, :text)}</figcaption>\n"
    html << "</figure>\n"
  end
end

Kramdown::Converter::Html.prepend(FigureImages)
