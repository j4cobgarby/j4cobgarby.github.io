---
layout: default
title: Some Projects
---

# Some Projects and Things

## Hackathon Projects

<div class="cardContainer">
{% for card in site.categories['hackathons'] %}
    {{ card }}
{% endfor %}
</div>

## Other Fun Projects

<div class="cardContainer">
{% for x in (1..7) %}
    <div class="card">

    </div>
{% endfor %}
</div>
