#!/usr/bin/env python3
"""Builds the Google Play listing images, and the pictures the website and
README use, from raw device captures.

    python3 tool/store/compose.py

Reads store/play/raw/*.png (1080x2400 captures of the app) and writes

  store/play/screenshots/NN-*.png   1242x2208, for the Play listing
  store/play/feature-graphic.png    1024x500
  docs/screenshots/NN-*.jpg         the same eight, lighter, for the web
  docs/screens/*.jpg                bare phone screens for the site's hero
  docs/showcase.jpg, icon.png, favicon.png

Each image is laid out as a small HTML page and photographed with headless
Chrome, then flattened to 24-bit, which is what Play accepts.
"""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
RAW = os.path.join(ROOT, 'store', 'play', 'raw')
OUT = os.path.join(ROOT, 'store', 'play')
DOCS = os.path.join(ROOT, 'docs')
FONTS = os.path.join(ROOT, 'assets', 'fonts')
ICON = os.path.join(ROOT, 'assets', 'icon', 'AppIcon~ios-marketing.png')
CHROME = os.environ.get(
    'CHROME', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')

# Backdrops, as (top-left, middle, bottom-right) of a diagonal gradient.
BLUE = ('#4C97FF', '#0A60E6', '#2A26BE')
VIOLET = ('#9A7BFF', '#6D3BE8', '#2B1470')
TEAL = ('#39C7E0', '#0B8FB0', '#0A3F6B')
EMBER = ('#FF9A6B', '#EE5526', '#7A1F3D')

# (output name, raw capture(s), headline, line under it, backdrop)
SHOTS = [
    ('01-natural-display', ['01-hero-dark'], 'Math, the way<br>you write it',
     'Fractions, roots and powers are typeset as you type.', BLUE),
    ('02-answer-forms', ['03-fraction-answer'], 'One answer,<br>three forms',
     'Press = again for a fraction or a rounded value.', BLUE),
    ('03-functions', ['02-functions'], 'Logs, roots,<br>absolute values',
     'The scientific keys you need, without the clutter.', TEAL),
    ('04-huge-numbers', ['04-huge'], 'Huge numbers,<br>no more Error',
     '999 to the power 99,999? It simply answers.', BLUE),
    ('05-saved-results', ['05-saved'], 'Save a result.<br>Reuse the sum.',
     'Paste back the answer, or the whole equation.', VIOLET),
    ('06-themes', ['06-themes-dark'], 'Nine themes.<br>Swipe to try.',
     'Free and premium looks, each in light and dark.', VIOLET),
    ('07-light-and-dark', ['07-hero-light', '01-hero-dark'],
     'Clean in light,<br>calm in dark', 'Follows your phone, or choose yourself.',
     BLUE),
    ('08-your-style', ['theme-rose-light', 'theme-ocean-dark'],
     'A look for<br>every mood', 'Rose, Sand, Citrus and more.', EMBER),
]

# Bare screens the website frames itself.
SITE_SCREENS = ['01-hero-dark', '07-hero-light', '06-themes-dark',
                '03-fraction-answer', '04-huge']

CSS = '''
@font-face{font-family:U;font-weight:800;src:url("file://%(fonts)s/Urbanist-ExtraBold.ttf")}
@font-face{font-family:U;font-weight:600;src:url("file://%(fonts)s/Urbanist-SemiBold.ttf")}
@font-face{font-family:U;font-weight:500;src:url("file://%(fonts)s/Urbanist-Medium.ttf")}
*{box-sizing:border-box}html,body{margin:0}
body{font-family:U;color:#fff;overflow:hidden;position:relative}
.bg{position:absolute;inset:0}
.glow{position:absolute;inset:0;background:radial-gradient(circle at 18%% 8%%,rgba(255,255,255,.30),rgba(255,255,255,0) 58%%)}
.phone{position:absolute;border-radius:var(--r);background:#0b0d12;padding:var(--b);
  box-shadow:0 50px 110px rgba(4,10,40,.50),0 0 0 2px rgba(255,255,255,.10) inset}
.screen{position:relative;width:100%%;height:100%%;border-radius:calc(var(--r) - var(--b));overflow:hidden}
.screen img{display:block;width:100%%}
/* Covers the notification icons the status bar picked up during capture. */
.patch{position:absolute;left:13.6%%;top:1.2%%;width:16%%;height:3%%}
'''


def pixel(path, x, y):
    """Colour of one pixel of an image, as a CSS rgb() string."""
    raw = subprocess.run(
        ['ffmpeg', '-v', 'error', '-i', path, '-vf', f'crop=1:1:{x}:{y}',
         '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'],
        capture_output=True, check=True).stdout
    return 'rgb(%d,%d,%d)' % tuple(raw[:3])


def phone(name, width, left, top, tilt=0):
    """A framed capture, `width` px wide, placed at (left, top)."""
    path = os.path.join(RAW, name + '.png')
    bezel = round(width * 0.021)
    height = round((width - 2 * bezel) * 2400 / 1080) + 2 * bezel
    style = (f'left:{left}px;top:{top}px;width:{width}px;height:{height}px;'
             f'--r:{round(width * 0.105)}px;--b:{bezel}px;'
             f'transform:rotate({tilt}deg)')
    return (f'<div class="phone" style="{style}"><div class="screen">'
            f'<img src="file://{path}">'
            f'<div class="patch" style="background:{pixel(path, 420, 62)}"></div>'
            f'</div></div>')


def backdrop(colors):
    a, b, c = colors
    return (f'<div class="bg" style="background:linear-gradient(135deg,{a},{b} 48%,{c})"></div>'
            '<div class="glow"></div>')


def screenshot_page(raws, headline, sub, colors):
    w, h = 1242, 2208
    if len(raws) == 1:
        phones = phone(raws[0], 770, (w - 770) // 2, 470)
    else:
        # Two phones, the second tucked behind and below the first.
        phones = (phone(raws[1], 640, 560, 660, 4)
                  + phone(raws[0], 640, 60, 500, -4))
    return (f'<style>{CSS % {"fonts": FONTS}}'
            'h1{position:absolute;left:92px;top:104px;margin:0;font-weight:800;'
            'font-size:104px;line-height:1.04;letter-spacing:-1.5px}'
            'p{position:absolute;left:96px;top:348px;right:90px;margin:0;font-weight:500;'
            'font-size:41px;line-height:1.25;opacity:.92}'
            f'</style><body style="width:{w}px;height:{h}px">{backdrop(colors)}'
            f'<h1>{headline}</h1><p>{sub}</p>{phones}</body>'), w, h


def feature_page():
    w, h = 1024, 500
    return (f'<style>{CSS % {"fonts": FONTS}}'
            '.icon{position:absolute;left:72px;top:84px;width:124px;height:124px;'
            'border-radius:28px;box-shadow:0 18px 40px rgba(4,10,40,.35),0 0 0 2px rgba(255,255,255,.35)}'
            'h1{position:absolute;left:70px;top:228px;margin:0;font-weight:800;font-size:86px;'
            'letter-spacing:-1.5px;line-height:1}'
            'p{position:absolute;left:74px;top:334px;width:400px;margin:0;font-weight:500;'
            'font-size:29px;line-height:1.25;opacity:.92}</style>'
            f'<body style="width:{w}px;height:{h}px">{backdrop(BLUE)}'
            f'<img class="icon" src="file://{ICON}"><h1>Calcu</h1>'
            '<p>The calculator that writes math the way you do.</p>'
            f'{phone("07-hero-light", 290, 590, 104, -6)}{phone("01-hero-dark", 290, 780, 44, 6)}'
            '</body>'), w, h


def screen_page(name):
    """One capture on its own, status-bar icons covered, for the website."""
    w, h = 720, 1600
    path = os.path.join(RAW, name + '.png')
    return (f'<style>{CSS % {"fonts": FONTS}}</style>'
            f'<body style="width:{w}px;height:{h}px"><div class="screen" '
            f'style="border-radius:0"><img src="file://{path}">'
            f'<div class="patch" style="background:{pixel(path, 420, 62)}"></div>'
            '</div></body>'), w, h


def convert(source, out, width=None):
    """Re-encodes an image as 24-bit PNG or JPEG, optionally narrower."""
    args = ['ffmpeg', '-v', 'error', '-y', '-i', source]
    if width:
        args += ['-vf', f'scale={width}:-2:flags=lanczos']
    # Play rejects PNGs with an alpha channel.
    args += ['-q:v', '3'] if out.endswith('.jpg') else ['-pix_fmt', 'rgb24']
    subprocess.run(args + [out], check=True)
    print('wrote', os.path.relpath(out, ROOT))


def render(html, width, height, out):
    with tempfile.TemporaryDirectory() as work:
        page = os.path.join(work, 'page.html')
        shot = os.path.join(work, 'shot.png')
        with open(page, 'w') as f:
            f.write('<!doctype html><meta charset="utf-8">' + html)
        subprocess.run(
            [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
             '--force-device-scale-factor=1', f'--window-size={width},{height}',
             '--virtual-time-budget=4000', f'--screenshot={shot}',
             f'file://{page}'],
            check=True, capture_output=True)
        convert(shot, out)


def main():
    shots = os.path.join(OUT, 'screenshots')
    web_shots = os.path.join(DOCS, 'screenshots')
    web_screens = os.path.join(DOCS, 'screens')
    for folder in (shots, web_shots, web_screens):
        os.makedirs(folder, exist_ok=True)

    for name, raws, headline, sub, colors in SHOTS:
        html, w, h = screenshot_page(raws, headline, sub, colors)
        render(html, w, h, os.path.join(shots, name + '.png'))
        convert(os.path.join(shots, name + '.png'),
                os.path.join(web_shots, name + '.jpg'), width=828)
    html, w, h = feature_page()
    render(html, w, h, os.path.join(OUT, 'feature-graphic.png'))

    # The website.
    for name in SITE_SCREENS:
        html, w, h = screen_page(name)
        render(html, w, h, os.path.join(web_screens, name + '.jpg'))
    convert(os.path.join(OUT, 'feature-graphic.png'),
            os.path.join(DOCS, 'showcase.jpg'))
    convert(ICON, os.path.join(DOCS, 'icon.png'), width=512)
    convert(ICON, os.path.join(DOCS, 'favicon.png'), width=64)


if __name__ == '__main__':
    sys.exit(main())
