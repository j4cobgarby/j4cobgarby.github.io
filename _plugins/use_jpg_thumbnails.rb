# Jekyll::Hooks.register :posts, :post_render do |doc|
#     # if doc.output_ext == ".html"
#     #   Jekyll.logger.debug "Modifying HTML: ", doc.relative_path
#     #   doc.output.gsub!(/<img.*?src=["'][^"']+\.jpg["']/i) do |match|
#     #     Jekyll.logger.debug "Replacing w/ groups: ", matc
#     #     match.gsub(/\.jpg/i, '_thumbnail.jpg')
#     #   end
#     # end
#   end

module Jekyll
  class Thumbnailer < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @img_name = text.strip
    end

    def render(context)
      thumb = @img_name.sub(/\.(\w+)$/, '_thumbnail.\1')
      "[![](#{thumb})](#{@img_name})"
    end
  end
end

Liquid::Template.register_tag('thumb', Jekyll::Thumbnailer)
# Liquid::Template.register_filter(Jekyll::Thumbnailer)