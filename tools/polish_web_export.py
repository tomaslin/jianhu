"""Brand Godot's generated HTML shell for portrait browsers/GitHub Pages.

Run after every `godot --headless --export-release Web index.html` command.
No CDN, tracking, remote scripts, external fonts, or hosting configuration.
"""

from pathlib import Path
import sys


def replace_once(text: str, before: str, after: str) -> str:
    if text.count(before) != 1:
        raise ValueError(f"Godot shell changed; expected one occurrence of {before[:55]!r}")
    return text.replace(before, after)


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: polish_web_export.py <index.html>")
    path = Path(sys.argv[1])
    html = path.read_text(encoding="utf-8")
    if 'name="jianghu-web-shell"' in html:
        print("Web shell already branded:", path)
        return
    html = replace_once(
        html,
        '<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">',
        '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">\n'
        '\t\t<meta name="theme-color" content="#182722">\n'
        '\t\t<meta name="apple-mobile-web-app-capable" content="yes">\n'
        '\t\t<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">\n'
        '\t\t<meta name="description" content="An ink-wash Jianghu pinball roguelike: eight worlds, living cities and four-form kung fu training.">\n'
        '\t\t<meta name="jianghu-web-shell" content="1">',
    )
    html = replace_once(html, 'src="index.png" alt=""', 'src="cover.webp" alt=""')
    html = replace_once(
        html,
        '\t\t\t<progress id="status-progress"></progress>',
        '\t\t\t<div id="loading-words">\n'
        '\t\t\t\t<div id="loading-kicker">A PHYSICS DREAM OF THE JIANGHU</div>\n'
        '\t\t\t\t<h1>Dreaming of<br>Jianghu</h1>\n'
        '\t\t\t\t<p>Eight painted worlds. A thousand strange collisions.</p>\n'
        '\t\t\t</div>\n'
        '\t\t\t<progress id="status-progress" aria-label="Loading the scroll"></progress>\n'
        '\t\t\t<div id="loading-foot">UNFURLING THE SCROLL &nbsp;·&nbsp; TOUCH TO PLAY</div>',
    )
    html = replace_once(
        html,
        '\t\t<noscript>',
        '\t\t<div id="rotate-hint">\n'
        '\t\t\t<span>↻</span> Turn your phone upright to enter Jianghu\n'
        '\t\t</div>\n\n'
        '\t\t<noscript>',
    )
    styles = """
/* Jianghu-web-shell: original atmospheric loading scene over Godot's canvas. */
html { height: 100%; background: #182722; }
body {
    height: 100%; height: 100dvh;
    background: radial-gradient(ellipse at 50% 30%, #405046 0%, #182722 66%);
    overscroll-behavior: none;
    -webkit-user-select: none;
    user-select: none;
    -webkit-tap-highlight-color: transparent;
}
#canvas { margin-inline: auto; touch-action: none; }
#status { z-index: 5; overflow: hidden; color: #f8ebce; background: #253129; }
#status-splash, #status-splash.fullsize--true {
    position: absolute; inset: 0; width: 100%; height: 100%;
    object-fit: cover; opacity: .77; filter: saturate(.78) contrast(.94);
}
#status::before {
    content: ""; position: absolute; inset: 0; z-index: 1;
    background: linear-gradient(180deg, rgba(12,28,24,.66), rgba(15,34,29,.22) 40%, rgba(12,28,24,.85) 92%);
    pointer-events: none;
}
#loading-words { position: absolute; z-index: 2; inset: 17% 12% auto; text-align: center;
    text-shadow: 0 2px 22px rgba(7,17,15,.7); }
#loading-kicker { letter-spacing: .23em; font: 600 11px/1.6 Georgia,serif; color: #e6c899; }
#loading-words h1 { margin: 20px 0 13px; font: 400 clamp(2.3rem,8vw,3.8rem)/1.07 Georgia,serif;
    letter-spacing: -.04em; }
#loading-words p { margin: 0; font: 13px/1.5 Georgia,serif; color: #f2ddbd; }
#status-progress { z-index: 3; width: min(68vw,310px); height: 6px; bottom: 15%;
    border: 1px solid rgba(254,228,182,.6); border-radius: 4px; overflow: hidden;
    background: rgba(12,26,22,.45); }
#status-progress::-webkit-progress-bar { background: rgba(12,26,22,.45); }
#status-progress::-webkit-progress-value { background: #d29870; }
#status-progress::-moz-progress-bar { background: #d29870; }
#loading-foot { position: absolute; z-index: 2; bottom: 9%; left: 12%; right: 12%;
    color: #e9d8b8; text-align: center; font: 10px/1.6 Georgia,serif; letter-spacing: .12em; }
#status-notice { z-index: 4; background: rgba(24,39,34,.95); color: #fff3dc;
    border-color: #b58b65; max-width: 34rem; }
#rotate-hint { display: none; }
@media (orientation: landscape) and (max-height: 550px) and (pointer: coarse) {
    #rotate-hint { display: flex; position: fixed; z-index: 6; inset: 0; padding: 2rem;
        align-items: center; justify-content: center; flex-direction: column; gap: 1.2rem;
        background: rgba(19,35,30,.97); color: #f0e0c3; text-align: center;
        font: 18px/1.5 Georgia,serif; }
    #rotate-hint span { font: 48px/1 Georgia,serif; }
}
@media (prefers-reduced-motion: reduce) { * { scroll-behavior: auto !important; } }
"""
    html = replace_once(html, '\t\t</style>', styles + '\n\t\t</style>')
    path.write_text(html, encoding="utf-8")
    print("Godot HTML shell branded:", path)


if __name__ == "__main__":
    main()
