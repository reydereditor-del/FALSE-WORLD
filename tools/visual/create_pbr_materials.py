#!/usr/bin/env python3
"""Author original seamless PBR textures; no downloaded photographs or screenshot art.

Optional offline authoring only: NumPy (BSD-3-Clause), Pillow (HPND), SciPy (BSD-3-Clause).
Godot and the game need none of these Python packages. Existing output is committed.
"""
from pathlib import Path
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter, distance_transform_edt, minimum_filter

SIZE = 1024
ROOT = Path(__file__).resolve().parents[2] / 'assets/visual/materials'


def fractal(rng):
    white = rng.random((SIZE, SIZE)).astype(np.float32)
    layers = [gaussian_filter(white, scale, mode='wrap') for scale in (2, 8, 32, 90)]
    normalized = [(a - a.mean()) / max(a.std(), 1e-5) for a in layers]
    return sum(a * w for a, w in zip(normalized, (0.16, 0.22, 0.30, 0.32)))


def save(name, albedo, roughness, height, metal=0.0, normal_strength=1.0):
    folder = ROOT / name
    folder.mkdir(parents=True, exist_ok=True)
    def image(file, data):
        Image.fromarray(np.uint8(np.clip(data, 0, 1) * 255)).save(folder / file)
    image('albedo.jpg', albedo)
    image('roughness.png', roughness)
    # Tangent-space OpenGL normal, derived from millimetre/centimetre relief.
    dx = (np.roll(height, -1, axis=1) - np.roll(height, 1, axis=1)) * normal_strength
    dy = (np.roll(height, -1, axis=0) - np.roll(height, 1, axis=0)) * normal_strength
    normals = np.stack((-dx, dy, np.ones_like(dx)), axis=-1)
    normals /= np.linalg.norm(normals, axis=-1, keepdims=True)
    image('normal.png', normals * 0.5 + 0.5)
    if isinstance(metal, np.ndarray):
        image('metallic.png', metal)


def main():
    rng = np.random.default_rng(1731)
    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    grain = rng.normal(0, 1, (SIZE, SIZE)).astype(np.float32)
    patch = fractal(rng)
    # Periodic poured-concrete panels, fine aggregate, mottled lime and cracks.
    seams = np.minimum(xx % 512, 512 - xx % 512) < 2
    seams |= np.minimum(yy % 512, 512 - yy % 512) < 2
    cracks = np.zeros((SIZE, SIZE), dtype=np.float32)
    for start, slope in [(104, .11), (642, -.17), (810, .07)]:
        line = (start + slope * yy + 9 * np.sin(yy / 31) + 4 * np.sin(yy / 7)) % SIZE
        cracks = np.maximum(cracks, np.exp(-((xx - line) / 1.1) ** 2))
    pits = gaussian_filter((rng.random((SIZE, SIZE)) > .992).astype(float), .7, mode='wrap')
    tone = .38 + .035 * patch + .008 * grain - .10 * cracks - .07 * seams - .13 * pits
    concrete = np.stack((tone * 1.02, tone * 1.0, tone * .92), axis=-1)
    relief = .08 * patch + .035 * grain - .45 * cracks - .4 * seams - pits * .4
    save('concrete', concrete, .86 + .055 * patch, relief, normal_strength=1.2)
    # Old olive paint on steel with irregular exposed steel and oxide islands.
    patch = fractal(rng)
    rust = np.clip((patch + .2) * 1.3, 0, 1)
    steel = np.array([.23, .27, .23])
    oxide = np.stack((.29 + .07 * grain, .145 + .025 * grain, .07 + .012 * grain), axis=-1)
    albedo = steel * (1 - rust[..., None]) + oxide * rust[..., None]
    albedo += (grain * .015)[..., None]
    for i in range(14):
        x = int(rng.integers(SIZE))
        albedo[:, x:x+1] *= .75
    height = gaussian_filter(rust, .8, mode='wrap') + .12 * grain
    save('steel', albedo, .42 + rust * .45, height, np.clip(1 - rust * 1.4, 0, 1), 1.4)
    # Aggregate stones in soil: geometric cells with recessed gaps and convex normals.
    seeds = rng.random((SIZE, SIZE)) > .985
    distance, indices = distance_transform_edt(~seeds, return_indices=True)
    stone_values = rng.uniform(.22, .34, (SIZE, SIZE))
    stone = stone_values[indices[0], indices[1]]
    boundaries = (np.abs(stone - np.roll(stone, 1, 0)) > .001) | (np.abs(stone - np.roll(stone, 1, 1)) > .001)
    edge = gaussian_filter(boundaries.astype(float), .8)
    height = gaussian_filter(stone, .7) * 3 - edge * 1.5 + grain * .04
    tone = stone - edge * .08 + grain * .005
    gravel = np.stack((tone * 1.05, tone * 1.03, tone * .93), axis=-1)
    save('gravel', gravel, .91 + .025 * grain, height, normal_strength=2.2)
    print('Authored three original 1024x1024 PBR sets in', ROOT)


if __name__ == '__main__':
    main()
