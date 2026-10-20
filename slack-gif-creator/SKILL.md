---
name: slack-gif-creator
description: "Create animated GIF (.gif) files optimized for Slack emoji at 128x128 and message at 480x480 using PIL/Pillow, with GIFBuilder, frame helpers, easing functions, validators, and animation patterns. Use when users ask to make, build, generate, or convert a Slack GIF, animated emoji, reaction GIF, loading spinner, bouncing heart, pulse, shake, vibrate, loop, or frame sequence for Slack."
---

# Slack GIF Creator

Create animated GIFs that meet Slack's size, color, and duration limits. This skill provides validation tools, a frame builder, easing functions, and reusable animation patterns using Pillow (PIL).

## When to use

- User asks for a Slack emoji GIF (128x128, <3s, 48-128 colors)
- User asks for a Slack message GIF (480x480, 10-30 FPS)
- User uploads an image and wants it animated or used as reference
- User wants to optimize an existing GIF for Slack upload

## Slack requirements

| Type | Dimensions | Max duration | FPS | Colors |
|------|------------|--------------|-----|--------|
| Emoji | 128x128 | 3 seconds | 10-30 | 48-128 |
| Message | 480x480 | No strict limit | 10-30 | 48-128 |

**Key limits**: Emoji files must stay under 128 KB. Lower FPS and fewer colors reduce file size.

## Core workflow

```python
from core.gif_builder import GIFBuilder
from PIL import Image, ImageDraw

builder = GIFBuilder(width=128, height=128, fps=10)

for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)
    # Draw animation frame using PIL primitives
    builder.add_frame(frame)

builder.save('output.gif', num_colors=48, optimize_for_emoji=True, remove_duplicates=True)
```

## Drawing graphics

### User-uploaded images

```python
from PIL import Image
uploaded = Image.open('user_file.png')
# Use directly as frames, or extract palette/style for reference
```

### Drawing from scratch with PIL primitives

```python
from PIL import ImageDraw

draw = ImageDraw.Draw(frame)

# Circles/ovals
draw.ellipse([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)

# Polygons (stars, triangles)
points = [(x1, y1), (x2, y2), (x3, y3)]
draw.polygon(points, fill=(r, g, b), outline=(r, g, b), width=3)

# Lines
draw.line([(x1, y1), (x2, y2)], fill=(r, g, b), width=5)

# Rectangles
draw.rectangle([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)
```

**Do not use** emoji fonts (render inconsistently) or assume pre-packaged graphics exist.

### Visual quality rules

- **Line weight**: Always use `width=2` or higher. Width=1 looks choppy.
- **Depth**: Use `create_gradient_background()` for backgrounds. Layer shapes (e.g., star inside star).
- **Detail**: Add highlights, rings, or glow layers (larger semi-transparent shape behind).
- **Color**: Use vibrant complementary pairs. High contrast outlines (dark on light, light on dark).
- **Complex shapes**: Build from multiple polygons/ellipses. Calculate points for symmetry. Add micro-details (heart highlight curve, snowflake branches).

## Available utilities

### GIFBuilder (`core.gif_builder`)

```python
builder = GIFBuilder(width=128, height=128, fps=10)
builder.add_frame(frame)           # Single PIL Image
builder.add_frames(list_of_frames) # Multiple frames
builder.save(
    'out.gif',
    num_colors=48,
    optimize_for_emoji=True,
    remove_duplicates=True
)
```

### Validators (`core.validators`)

```python
from core.validators import validate_gif, is_slack_ready

passes, info = validate_gif('my.gif', is_emoji=True, verbose=True)
# info contains: width, height, frames, fps, colors, file_size, duration

if is_slack_ready('my.gif'):
    print('Ready for Slack')
```

### Easing functions (`core.easing`)

```python
from core.easing import interpolate

t = i / (num_frames - 1)  # 0.0 to 1.0
y = interpolate(start=0, end=400, t=t, easing='ease_out')
# Options: linear, ease_in, ease_out, ease_in_out, bounce_out, elastic_out, back_out
```

### Frame helpers (`core.frame_composer`)

```python
from core.frame_composer import (
    create_blank_frame,
    create_gradient_background,
    draw_circle,
    draw_text,
    draw_star
)
```

## Animation patterns

### Shake / Vibrate

```python
import math
offset_x = math.sin(frame_idx * 0.8) * 3
# Add small random jitter for natural feel
```

### Pulse / Heartbeat

```python
scale = 1.0 + 0.2 * math.sin(t * frequency * 2 * math.pi)
# Heartbeat: two quick pulses then pause — adjust frequency per segment
```

### Bounce

```python
# Falling: ease_in (accelerating)
# Landing: bounce_out
y = interpolate(start=-50, end=ground_y, t=t, easing='bounce_out')
```

### Spin / Rotate

```python
rotated = image.rotate(angle, resample=Image.BICUBIC)
# Wobble: angle = base_angle + math.sin(t * 6) * 15
```

### Fade in / out

```python
# Use RGBA and adjust alpha
frame.putalpha(int(255 * alpha))
# Or blend: Image.blend(transparent_bg, frame, alpha)
```

### Slide

```python
x = interpolate(start=-width, end=target_x, t=t, easing='ease_out')
# Overshoot: easing='back_out'
```

### Zoom

```python
# Zoom in: scale 0.1 to 2.0, crop center
# Zoom out: scale 2.0 to 1.0
scaled = frame.resize((int(w*scale), int(h*scale)), Image.BICUBIC)
```

### Explode / Particle burst

```python
particles = [{'x': cx, 'y': cy, 'vx': vx, 'vy': vy, 'alpha': 255} for _ in range(20)]
for p in particles:
    p['x'] += p['vx']
    p['y'] += p['vy']
    p['vy'] += gravity  # 0.5 per frame
    p['alpha'] = max(0, p['alpha'] - fade_rate)
    # Draw circle at (p['x'], p['y']) with alpha
```

## Optimization (apply when file size too large)

1. Reduce FPS (10 instead of 20)
2. Reduce colors (`num_colors=48`)
3. Reduce dimensions (128x128 for emoji)
4. Shorten duration (fewer frames)
5. Enable `remove_duplicates=True` in save()
6. Use `optimize_for_emoji=True` (auto-applies best settings)

```python
builder.save(
    'emoji.gif',
    num_colors=48,
    optimize_for_emoji=True,
    remove_duplicates=True
)
```

## Validation checklist

- [ ] Dimensions match target (128x128 emoji, 480x480 message)
- [ ] Frame count × (1/FPS) ≤ 3s for emoji
- [ ] Color count ≤ 128 (48 recommended for emoji)
- [ ] File size < 128 KB for emoji
- [ ] No duplicate consecutive frames
- [ ] Animation loops cleanly (last frame connects to first)

## Dependencies

```bash
pip install pillow imageio numpy
```

## Philosophy

This skill provides **knowledge** (Slack specs, animation math), **utilities** (builder, validators, easing), and **flexibility** (you write the frame logic with PIL). It does not provide rigid templates, emoji fonts, or a built-in graphics library. Combine patterns freely (bounce + rotate, pulse + slide) and use PIL's full drawing API.

## Related skills

Load these when the task spans more than this skill.

- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
- [`meme-factory`](../meme-factory/SKILL.md) — Generate memes with the free memegen.link API. Use when you need a quick, contextual meme for chat, code revie…
- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
