# Three.js

API references for Three.js r186 on WebGL and WebGPU/TSL, and for React Three Fiber.

## When to use

- You build a 3D scene, a product viewer, or a WebGL hero section.
- You need the exact Three.js API for a camera, light, material, loader, shader, or effect.
- You port WebGL code to WebGPURenderer and TSL node materials.
- You write React components that render Three.js with React Three Fiber and drei.
- A 3D scene is slow, or a model or texture is too large.

Load only the file that matches the task. For scroll storytelling and the 3D design workflow, see [`immersive-web.md`](immersive-web.md).

| File | Use when |
|---|---|
| [`threejs-fundamentals`](threejs/threejs-fundamentals.md) | You create a scene from scratch, set up a camera or renderer, handle resize, or arrange objects. |
| [`threejs-geometry`](threejs/threejs-geometry.md) | You build 3D shapes or text, custom vertex data, custom meshes, instanced meshes, or point clouds. |
| [`threejs-materials`](threejs/threejs-materials.md) | You style meshes or tune material behavior (unlit, PBR, toon, points, lines, node materials). |
| [`threejs-textures`](threejs/threejs-textures.md) | You put images on materials, or work with UV coordinates, cubemaps, render targets, or texture memory. |
| [`threejs-lighting`](threejs/threejs-lighting.md) | You add or tune lights, fix shadow acne, set up image-based lighting, or dim an environment map. |
| [`threejs-loaders`](threejs/threejs-loaders.md) | You load 3D models, textures, or environment maps, or manage loading progress. |
| [`threejs-asset-pipeline`](threejs/threejs-asset-pipeline.md) | You compress, optimize, or validate glTF models before you load them. |
| [`threejs-animation`](threejs/threejs-animation.md) | You animate objects, play glTF animations, pose bones, drive morph targets, or blend clips. |
| [`threejs-interaction`](threejs/threejs-interaction.md) | You handle mouse, touch, or keyboard input, pick 3D objects, add camera controls, or make objects interactive. |
| [`threejs-shaders`](threejs/threejs-shaders.md) | You write a shader or a custom material, move vertices in a shader, or port GLSL to TSL. |
| [`threejs-postprocessing`](threejs/threejs-postprocessing.md) | You add screen effects: bloom, depth of field, ambient occlusion, color grading, blur, or glow. |
| [`threejs-performance`](threejs/threejs-performance.md) | A scene is slow, has jank, or uses too much memory. |
| [`threejs-react-three-fiber`](threejs/threejs-react-three-fiber.md) | You write React components that render Three.js. |

## Notes

Source: [cloudai-x/threejs-skills](https://github.com/cloudai-x/threejs-skills). MIT license, Copyright (c) 2026 CloudAI-X.
