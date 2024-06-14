const msg_hide = "Hide sidebar";
const msg_show = "Show sidebar";

function toggle_sidebar () {
    sdb = document.getElementById("sidebar");
    btn = document.getElementById("sidebar-toggle");

    if (sdb.classList.contains("hidden")) {
        sdb.classList.remove("hidden");
        btn.innerHTML = msg_hide;
        sessionStorage.setItem("sidebarState","visible");
    } else {
        sdb.classList.add("hidden");
        btn.innerHTML = msg_show;
        sessionStorage.setItem("sidebarState","hidden");
    }
}

function init() {
    document.getElementById("sidebar-toggle").innerHTML = msg_hide;
    if (sessionStorage.getItem("sidebarState") == "hidden") {
        toggle_sidebar();
    }
}

window.onscroll = function() {
if (document.body.scrollTop > 60 || document.documentElement.scrollTop > 60) {
    document.querySelector(".stickybox").classList.add("sticking");
  } else {
    document.querySelector(".stickybox").classList.remove("sticking");
  }
};
