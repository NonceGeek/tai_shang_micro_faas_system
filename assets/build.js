const esbuild = require('esbuild')

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
  '.ttf': 'file'
}

const plugins = [
  // Add and configure plugins here
]

const workerEntryPoints = [
  'vs/language/json/json.worker.js',
  'vs/language/css/css.worker.js',
  'vs/language/html/html.worker.js',
  'vs/language/typescript/ts.worker.js',
  'vs/editor/editor.worker.js'
];

function build(opts) {
  esbuild.build(opts).then((result) => {
    if (result.errors.length > 0) {
      console.error(result.errors);
    }
    if (result.warnings.length > 0) {
      console.error(result.warnings);
    }
  });
}

build({
  entryPoints: workerEntryPoints.map((entry) => `./node_modules/monaco-editor/esm/${entry}`),
  bundle: true,
  format: 'iife',
  outbase: './node_modules/monaco-editor/esm/',
  outdir: '../priv/static/assets'
});

let opts = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/assets',
  logLevel: 'info',
  loader,
  plugins
}

if (watch) {
  opts = {
    ...opts,
    watch,
    sourcemap: 'inline'
  }
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  }
}

const promise = esbuild.build(opts)

if (watch) {
  promise.then(_result => {
    process.stdin.on('close', () => {
      process.exit(0)
    })

    process.stdin.resume()
  })
}
