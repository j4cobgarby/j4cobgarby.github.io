#!/usr/bin/env python3

import PIL
from PIL import Image
import sys
import os

def process_dir(dirname):
    dir = os.fsencode(dirname)

    for root, dirs, files in os.walk(dir):
        for f in files:
            if f.endswith(b'.jpg') or f.endswith(b'.jpeg'):
                whole_path = os.path.join(root, f)
                base, ext = os.path.splitext(f)
                save_to = os.path.join(root, base + b'_thumbnail' + ext)

                if b'thumbnail' in f:
                    continue
                if os.path.exists(save_to):
                    print(f"Thumbnail already exists for {whole_path}")
                    continue

                print(f"Thumbnailing {whole_path}")
                img = Image.open(whole_path)
                img.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
                print(f" -> Created {save_to}")
                img.save(save_to, quality=90, optimize=True)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} root_dir")
        sys.exit(-1)

    process_dir(sys.argv[1])
