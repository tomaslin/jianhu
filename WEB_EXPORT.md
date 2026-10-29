# Web build for GitHub Pages

The live game is **[Dreaming of Jianghu](https://tomaslin.github.io/jianhu/)**.
Build it with Godot 4.7.2 and the included single-threaded Web preset.

## Recommended: automatic GitHub Pages deployment

Upload the **contents of the Godot source project** to the root of a GitHub
repository with default branch `main`. Under **Settings → Pages**, choose
**Source: GitHub Actions**. Enable this once as a repository administrator;
the workflow token cannot create a Pages site. The included `.github/workflows/pages.yml`
performs fresh Godot asset imports, 1,022+ mechanic and state-transition tests,
eight-world live-physics trajectory tests, a real single-threaded WebAssembly
export, and structural JS/PCK/WASM verification before uploading and
deploying. Pull requests test but do not publish. Successful deployments are
verified by a live request for `index.html` and `index.wasm`.

This requires repository write access and GitHub Pages permissions; a zipped
project in isolation does **not** publish itself.

## Manual rebuild (or the standalone web ZIP)

1. Install **Godot 4.7.2** and its official export templates.
2. Make a sibling directory named `Dreaming_of_Jianghu_Web` if needed.
3. From the Godot project directory, run:

   ```sh
   godot --headless --path . --export-release Web ../Dreaming_of_Jianghu_Web/index.html
   cp web/cover.webp ../Dreaming_of_Jianghu_Web/cover.webp
   touch ../Dreaming_of_Jianghu_Web/.nojekyll
   python3 tools/polish_web_export.py ../Dreaming_of_Jianghu_Web/index.html
   python3 tools/verify_web_export.py ../Dreaming_of_Jianghu_Web
   ```

4. If you are uploading *only the compiled web build* rather than the Godot
   source, commit the **web directory contents** to a separate GitHub
   repository root and enable Pages branch deployment, `main` / `(root)`.

The helper `tools/extract_web_templates.py` can retrieve only the two official
single-threaded web templates if the complete export template download is too
large. It requires network access and an HTTP server supporting byte ranges.

The final HTML is branded but uses the generated Godot `Engine` loader and
native `index.js`, `index.wasm`, and `index.pck`. No gameplay has been rewritten
in JavaScript. Run smoke/trajectory tests on the source game before shipping.

The shell fits a 390 × 844 portrait frame inside Safari’s available viewport,
respects safe-area insets, and resizes the canvas when the browser chrome or
window changes. Keep the Web canvas resize policy at **None**: the shell
controls the backing-buffer size, while Godot preserves the game’s aspect ratio.
