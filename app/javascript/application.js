// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { init as initOrderingApp } from "ordering_app"

// turbo:load fires on the first visit and on every Turbo Drive navigation.
// DOMContentLoaded alone leaves #app blank when returning via Order / logo links.
document.addEventListener("turbo:load", () => {
  if (document.getElementById("app")) {
    initOrderingApp();
  }
})
