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

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

import * as monaco from 'monaco-editor/esm/vs/editor/editor.main.js';

self.MonacoEnvironment = {
  getWorkerUrl: function (moduleId, label) {
    if (label === 'json') {
      return './assets/vs/editor/json.worker.bundle.js';
    }
    if (label === 'css' || label === 'scss' || label === 'less') {
      return './assets/vs/editor/css.worker.bundle.js';
    }
    if (label === 'html' || label === 'handlebars' || label === 'razor') {
      return './assets/vs/editor/html.worker.bundle.js';
    }
    if (label === 'typescript' || label === 'javascript') {
      return './assets/vs/editor/ts.worker.bundle.js';
    }
    return './assets/vs/editor/editor.worker.js';
  }
};

function highlightCode(code_text) {
  const editor = monaco.editor.create(document.getElementById('code-loaded'), {
    value: code_text,
    domReadOnly: true,
    readOnly: true,
    automaticLayout: true,
    scrollBeyondLastLine: false,
    language: 'elixir'
  });
  const contentHeight = editor.getModel().getLineCount() * 19;
  editor.layout({ height: contentHeight });
}

window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => {
  topbar.hide()
})

window.addEventListener(`phx:highlight`, (e) => {
  highlightCode(e.detail.code_text)
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
