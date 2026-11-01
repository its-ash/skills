# Manim Video

Build reusable Manim explainers for technical concepts, graphs, system diagrams, and product walkthroughs, where motion, structure, and clarity matter more than photorealism.

## When to use

- The user wants a technical explainer animation.
- The concept is a graph, workflow, architecture, metric progression, or system diagram.
- The user wants a short product or launch explainer for X or a landing page.
- The visual must feel precise, not generically cinematic.

## Tool requirements

- `manim` CLI (Manim Community) for scene rendering
- `ffmpeg` for post-processing if necessary
- [video-production](../SKILL.md) for final assembly and polish
- [remotion.md](remotion.md) when the final package needs composited UI, captions, or more motion layers

## Default output

- Short 16:9 MP4
- One thumbnail or poster frame
- Storyboard and scene plan

## Workflow

1. Define the core visual thesis in one sentence.
2. Break the concept into 3 to 6 scenes.
3. Decide what each scene proves.
4. Write the scene outline before you write Manim code.
5. Render the smallest working version first.
6. Tighten typography, spacing, color, and pacing after the render works.
7. Hand off to the wider video stack only if it adds value.

## Scene planning rules

- Each scene proves one thing.
- Do not overstuff diagrams.
- Prefer progressive reveal to full-screen clutter.
- Use motion to explain a state change, not to keep the screen busy.
- Keep title cards short and full of meaning.

## Network graph default

For social-graph and network-optimization explainers:

- Show the current graph before the optimized graph.
- Make low-signal follow clutter look different from high-signal bridges.
- Highlight warm-path nodes and target clusters.

## Render conventions

- Default to 16:9 landscape unless the user asks for vertical.
- Start with a low-quality smoke test render (`-ql`).
- Go to higher quality (`-qh`) only after composition and timing are stable.
- Export one clean thumbnail frame that reads at social size (`-s` saves the last frame).

## Starter scene

Save as `network_graph_scene.py`, then smoke-test with `manim -ql network_graph_scene.py NetworkGraphExplainer`.

```python
from manim import DOWN, LEFT, RIGHT, UP, Circle, Create, CurvedArrow, FadeIn, FadeOut, Scene, Text, VGroup


class NetworkGraphExplainer(Scene):
    def construct(self):
        title = Text("Connections Optimizer", font_size=40).to_edge(UP)
        subtitle = Text("Prune low-signal follows. Strengthen warm paths.", font_size=20).next_to(title, DOWN)

        you = Circle(radius=0.45, color="#4F8EF7").shift(LEFT * 4 + DOWN * 0.5)
        stale_a = Circle(radius=0.32, color="#7A7A7A").shift(LEFT * 1.6 + UP * 1.2)
        stale_b = Circle(radius=0.32, color="#7A7A7A").shift(LEFT * 1.2 + DOWN * 1.4)
        bridge = Circle(radius=0.38, color="#21A179").shift(RIGHT * 0.2 + UP * 0.2)
        target = Circle(radius=0.42, color="#FF9F1C").shift(RIGHT * 3.2 + UP * 0.7)
        new_target = Circle(radius=0.42, color="#FF9F1C").shift(RIGHT * 3.0 + DOWN * 1.4)

        def label(text, node):
            return Text(text, font_size=18).move_to(node.get_center())

        you_label = Text("You", font_size=22).move_to(you.get_center())
        stale_a_label, stale_b_label = label("stale", stale_a), label("noise", stale_b)
        bridge_label, target_label = label("bridge", bridge), label("target", target)
        new_target_label = label("add", new_target)

        edge_stale_a = CurvedArrow(you.get_right(), stale_a.get_left(), angle=0.2, color="#7A7A7A")
        edge_stale_b = CurvedArrow(you.get_right(), stale_b.get_left(), angle=-0.2, color="#7A7A7A")
        edge_bridge = CurvedArrow(you.get_right(), bridge.get_left(), angle=0.0, color="#21A179")
        edge_target = CurvedArrow(bridge.get_right(), target.get_left(), angle=0.1, color="#21A179")
        edge_new = CurvedArrow(bridge.get_right(), new_target.get_left(), angle=-0.12, color="#21A179")

        self.play(FadeIn(title), FadeIn(subtitle))
        self.play(
            *[Create(n) for n in (you, stale_a, stale_b, bridge, target)],
            *[FadeIn(t) for t in (you_label, stale_a_label, stale_b_label, bridge_label, target_label)],
        )
        self.play(Create(edge_stale_a), Create(edge_stale_b), Create(edge_bridge), Create(edge_target))

        self.play(FadeIn(Text("Optimize the graph", font_size=24).to_edge(DOWN)))
        self.play(*[FadeOut(m) for m in (stale_a, stale_b, stale_a_label, stale_b_label, edge_stale_a, edge_stale_b)])
        self.play(Create(new_target), FadeIn(new_target_label), Create(edge_new))

        final_group = VGroup(you, you_label, bridge, bridge_label, target, target_label, new_target, new_target_label)
        self.play(final_group.animate.shift(UP * 0.1))
        self.wait(1)
```

## Output format

Return:

- Core visual thesis
- Storyboard
- Scene outline
- Render plan
- Follow-on polish recommendations, if any
