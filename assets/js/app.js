// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import { web3AccountInit } from "./web3_account"
import Alpine from 'alpinejs'

web3AccountInit()

window.Alpine = Alpine
Alpine.start()

let Hooks = {}
Hooks.Web3Account = {
  mounted() {
    this.el.addEventListener("web3-changed", event => {
      this.pushEventTo('#web3-account', 'web3-changed', event.detail)
    })
    this.el.addEventListener("send-signed-message", event => {
      this.pushEventTo('#web3-account', 'send-signed-message', event.detail)
    })
    this.handleEvent("message-verified", ({ result }) => {
      const el = document.getElementById('web3-account')
      el.dispatchEvent(new CustomEvent('messageverified', { detail: { result } }))
    })
  }
}
Hooks.AuthAsBuidler = {
  mounted() {
    document.addEventListener('requested_auth', event => {
      this.pushEventTo('#auth_as_buidler', 'auth-as-builder', event.detail)
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  metadata: {
    click: (e, el) => {
      return {
        detail: e.detail
      }
    }
  },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  },
  hooks: Hooks
})


// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

function highlightCode() {
  let el = document.getElementById("code-loaded")
  if (el) {
    hljs.highlightAll();
  }
}

window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => {
  topbar.hide()
  highlightCode()
})

window.addEventListener(`phx:highlight`, (e) => {
  highlightCode()
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
