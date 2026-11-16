"""Calcu icon. Writes the SVG layers for the launcher and store icons."""
import math, os
OUT = os.path.dirname(os.path.abspath(__file__))
BLUE = '#0A60E6'

def bar(x1, y1, x2, y2, color, w):
    """A rounded bar as a path (a zero-area <line> drops out under filters)."""
    return (f'<path d="M {x1} {y1} L {x2} {y2}" fill="none" stroke="{color}" '
            f'stroke-width="{w}" stroke-linecap="round"/>')

def sym(kind, cx, cy, color, w, r):
    if kind == '+': return bar(cx-r,cy,cx+r,cy,color,w) + bar(cx,cy-r,cx,cy+r,color,w)
    if kind == '-': return bar(cx-r,cy,cx+r,cy,color,w)
    if kind == 'x':
        d = r*0.72
        return bar(cx-d,cy-d,cx+d,cy+d,color,w) + bar(cx-d,cy+d,cx+d,cy-d,color,w)
    gap = r*0.50
    return bar(cx-r,cy-gap,cx+r,cy-gap,color,w) + bar(cx-r,cy+gap,cx+r,cy+gap,color,w)

CELLS = [('+',0,0),('-',1,0),('x',0,1),('=',1,1)]

def layout(span):
    """Tile size and gap for a 2x2 block `span` px wide, centred on 512."""
    gap = span*0.075
    tile = (span-gap)/2
    x0 = 512-span/2
    return tile, gap, x0

def keys(span, mode='color'):
    tile, gap, x0 = layout(span)
    w, r, rr = tile*0.155, tile*0.255, tile*0.27
    out = []
    for kind, i, j in CELLS:
        x, y = x0+i*(tile+gap), x0+j*(tile+gap)
        mx, my = x+tile/2, y+tile/2
        box = f'x="{x:.1f}" y="{y:.1f}" width="{tile:.1f}" height="{tile:.1f}" rx="{rr:.1f}"'
        if mode == 'mono':
            # One colour only: outlined keys, and the = cut out of a solid one.
            if kind == '=':
                out.append(f'<mask id="cut"><rect width="1024" height="1024" fill="#fff"/>{sym(kind,mx,my,"#000",w,r)}</mask>')
                out.append(f'<rect {box} fill="#fff" mask="url(#cut)"/>')
            else:
                s = tile*0.07
                out.append(f'<rect x="{x+s/2:.1f}" y="{y+s/2:.1f}" width="{tile-s:.1f}" height="{tile-s:.1f}" rx="{rr-s/2:.1f}" fill="none" stroke="#fff" stroke-width="{s:.1f}"/>')
                out.append(sym(kind,mx,my,'#fff',w,r))
        elif kind == '=':
            out.append(f'<rect {box} fill="#fff" filter="url(#lift)"/>')
            out.append(sym(kind,mx,my,BLUE,w,r))
        else:
            out.append(f'<rect {box} fill="url(#glass)" stroke="#fff" stroke-opacity=".34" stroke-width="3"/>')
            out.append(sym(kind,mx,my,'#fff',w,r))
    return ''.join(out)

DEFS = '''
<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
  <stop offset="0" stop-color="#4C97FF"/><stop offset=".48" stop-color="#0A60E6"/><stop offset="1" stop-color="#2A26BE"/>
</linearGradient>
<radialGradient id="shine" cx=".2" cy=".1" r=".8">
  <stop offset="0" stop-color="#fff" stop-opacity=".32"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>
</radialGradient>
<linearGradient id="glass" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="#fff" stop-opacity=".26"/><stop offset="1" stop-color="#fff" stop-opacity=".12"/>
</linearGradient>
<filter id="lift" x="-40%" y="-40%" width="180%" height="190%">
  <feDropShadow dx="0" dy="18" stdDeviation="20" flood-color="#04155C" flood-opacity=".45"/>
</filter>'''
BACK = '<rect width="1024" height="1024" fill="url(#bg)"/><rect width="1024" height="1024" fill="url(#shine)"/>'

def svg(body, clip=None):
    pre = ''
    if clip is not None:
        pre = f'<clipPath id="round"><rect x="{clip[0]}" y="{clip[0]}" width="{1024-2*clip[0]}" height="{1024-2*clip[0]}" rx="{clip[1]}"/></clipPath>'
        body = f'<g clip-path="url(#round)">{body}</g>'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">'
            f'<defs>{DEFS}{pre}</defs>{body}</svg>')

def c_equals():
    cx, cy, r, w = 472, 512, 226, 108
    a = math.radians(48)
    x1, y1 = cx+r*math.cos(a), cy-r*math.sin(a)
    x2, y2 = cx+r*math.cos(a), cy+r*math.sin(a)
    arc = f'<path d="M {x1:.1f} {y1:.1f} A {r} {r} 0 1 0 {x2:.1f} {y2:.1f}" fill="none" stroke="#fff" stroke-width="{w}" stroke-linecap="round"/>'
    bars = ''.join(f'<rect x="556" y="{y-30}" width="224" height="60" rx="30" fill="#fff"/>' for y in (460, 564))
    return f'<g filter="url(#lift)">{arc}{bars}</g>'

FILES = {
    # Full-bleed square: Play Store listing and iOS.
    'full': svg(BACK + keys(580)),
    # Android adaptive layers. The launcher XML insets the foreground by 16%,
    # so the glyph is drawn large enough to survive that.
    'foreground': svg(keys(600)),
    'background': svg(BACK),
    'monochrome': svg(keys(600, 'mono')),
    # Pre-Android-8 launchers draw the image as it is: give it its own shape.
    'legacy': svg(BACK + keys(540), clip=(44, 208)),
    'alt-letter': svg(BACK + c_equals()),
}
for name, s in FILES.items():
    open(f'{OUT}/{name}.svg', 'w').write(s)
print(sorted(FILES))
