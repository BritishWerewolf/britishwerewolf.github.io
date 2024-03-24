document.getElementsByClassName("theme-switcher")[0].onclick = function (event) {
    document.documentElement.dataset["theme"] = document.documentElement.dataset["theme"] == "dark"
    ? "light"
    : "dark";
    localStorage.setItem("theme", document.documentElement.dataset["theme"]);
};

if (localStorage.getItem("theme")) {
    document.documentElement.dataset["theme"] = localStorage.getItem("theme");
} else if (window.matchMedia) {
    document.documentElement.dataset["theme"] = window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
} else {
    document.documentElement.dataset["theme"] = "dark";
}
