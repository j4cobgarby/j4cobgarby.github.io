---
layout: post
author: Jacob Garby
title: Winter Photos and Technical Site Update
---

### Photos

For most of winter I haven't been going out and taking any photos. It's been too dark, and (almost) all the birds have migrated south.

Last weekend, however, I took a very short -- five minute -- train up to Jonsered, and got a few nice images.

![](https://nc.jgarby.uk/s/X6itGC4aA2KrDjF/preview)

Here we can see the train to Alingsås approaching. I thought this was a pretty cool picture with that blurry chap in the foreground. In fact, the reason he's quite _so_ out of focus is that I was using a super long lens here, my 150-600mm Tamron, at close to full zoom. It's a really fun lens to use, but really really heavy, and slightly hard to hold still. The active stabilisation helps.

The last photo for today is the following magpie.

![](https://nc.jgarby.uk/s/CNXfzMPxsegpFew/preview)

This demonstrates a bit better what this lens is capable of. It's not completely sharp, especially around the magpie's dishevelled facial fluff. I think this is likely to be my fault though, I still haven't quite got the hang of what kind of shutter speed I need to take sharp hand-held photos with this.

Funnily enough, although I did get to Jonsered for my walk, I didn't get any good photos there at all. The magpie was just sitting on a street-tree, so to speak.

### Site Update

I thought that it wasn't ideal to provide full-res versions of the images on these blog posts, just because they're tens of megabytes and will add a lot to page load times. I fiddled around a bit with Jekyll (and a little Python script) so that I store a thumbnail version and a full version. Now, if you try clicking on one of these images you'll get to download the full version!

I had to get a bit familiar with how Jekyll uses Liquid to do this, but it came down to this:

```ruby
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
```

Basically, whenever I write something like `{% thumb my_image.jpg %}` it will substitute this for a bit of markdown consisting of an image (`my_image_thumbnail.jpg`) within a link to the original image. It works quite well and is a lot easier for me than if I had to type that out manually every time.

For actually creating these thumbnail images, I use Python with Pillow. If you're curious or want to use it yourself, you're welcome to look at it [here](https://github.com/j4cobgarby/j4cobgarby.github.io/blob/main/minify_big_jpegs.sh). Right now I just run this script manually when I upload new images, but in an ideal world my ruby code would be generating thumbnails when needed, on the fly. That's a project for another day, I reckon.
