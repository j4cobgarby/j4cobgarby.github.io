---
layout: default
title: Some Projects
---

# Some Projects and Things

Below is a mix of hackathon projects (that I've worked on in a team with friends), and personal projects. Make sure to click the title of projects that seem interesting to you, because then you can see more information and content related to them.

Of course it goes without saying that everything is open source, and in most cases the titular link will take you either directly to the source, or to a Devpost page from which you can find a Github link.

<div class="cardContainer">
{% for card in site.categories['projects'] %}
    {{ card }}
{% endfor %}
</div>
