---
layout: post
author: jacob
---

Lorem ipsum this is some random text. Will it be before or after the first post? Who knows?

Also, here's some code;

```c
int find_free_frames() {
    unsigned long int ret = 0;
    struct limine_memmap_response *resp = memmap_request.response;

    for (uint64_t i = 0; i < resp->entry_count; i++) {
        struct limine_memmap_entry *entry = resp->entries[i];

        if (entry->type == LIMINE_MEMMAP_USABLE) {
            for (uint64_t b_offset = 0; b_offset < entry->length; b_offset += 4096) {
                struct frame_marker *new_block = (struct frame_marker*)(entry->base + b_offset);

                // Put the metadata in the new block, saying where the next block in the linked
                // list is located.
                new_block->next_frame = first_page_frame;

                // Make the linked list start at the new block.
                first_page_frame = new_block;

                ret++;
            }
        }
    }

    return ret;
}
```
_Fig 1: Some code._

Back to normal text.