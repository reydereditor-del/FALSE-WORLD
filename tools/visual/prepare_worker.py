"""Run with Blender --background --python THIS -- --source PATH --output PATH.

CC-BY-4.0 Cesium Man derivative: discard branded images/materials, retain mesh/rig/walk,
and add original neutral workwear vertex colors. No runtime Blender dependency.
"""
import argparse
import sys
import bpy
from mathutils import Vector

parser = argparse.ArgumentParser()
parser.add_argument('--source', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=args.source)
bpy.context.view_layer.update()
meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH' and obj.vertex_groups]
for obj in meshes:
    print('Imported character', obj.name, 'dimensions', obj.dimensions[:])
    obj.data.materials.clear()
    material = bpy.data.materials.new('OriginalUnbrandedWorkwear')
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get('Principled BSDF')
    colors = material.node_tree.nodes.new('ShaderNodeVertexColor')
    colors.layer_name = 'Workwear'
    material.node_tree.links.new(colors.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 0.88
    obj.data.materials.append(material)
    corners = obj.data.color_attributes.new(name='Workwear', type='FLOAT_COLOR', domain='CORNER')
    evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    deformed = evaluated.to_mesh()
    positions = [evaluated.matrix_world @ vertex.co for vertex in deformed.vertices]
    lo = min(point.z for point in positions)
    hi = max(point.z for point in positions)
    for loop in obj.data.loops:
        p = positions[loop.vertex_index]
        t = (p.z - lo) / (hi - lo)
        color = (0.045, 0.052, 0.048, 1) if t < 0.12 else (0.10, 0.12, 0.115, 1)
        if t > 0.48:
            color = (0.24, 0.27, 0.22, 1)
        if t > 0.86:
            color = (0.53, 0.39, 0.29, 1)
        corners.data[loop.index].color = color
    evaluated.to_mesh_clear()
# Strip all source image datablocks and unused branded materials before export.
for image in list(bpy.data.images):
    bpy.data.images.remove(image)
for material in list(bpy.data.materials):
    if material.name != 'OriginalUnbrandedWorkwear':
        bpy.data.materials.remove(material)
for action in bpy.data.actions:
    action.name = 'Walk'
print('Actions:', [action.name for action in bpy.data.actions])
bpy.ops.export_scene.gltf(filepath=args.output, export_format='GLB', export_animations=True,
                           export_skins=True, export_yup=True, export_apply=False)
print('Exported unbranded worker to', args.output)
