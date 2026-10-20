---
name: geopandas
description: "Read, write, transform, and analyze vector geospatial data with GeoPandas across Shapefile, GeoJSON, GeoPackage, Parquet, and PostGIS formats. Use when you need to reproject CRS, buffer, intersect, union, dissolve, clip, sjoin, overlay, spatial join, calculate area, distance, centroid, bounds, simplify geometry, plot choropleth, export to file, load from database, handle multipolygon, linestring, point geometry, or fix invalid topology."
---

# GeoPandas

GeoPandas extends pandas for vector geospatial data. Use it to read, transform, analyze, and map points, lines, and polygons across common spatial formats.

## When to use

- Read or write vector spatial data.
- Manage CRS and reproject data.
- Calculate area, length, distance, centroids, and buffers.
- Run spatial joins, nearest-neighbor joins, overlays, clips, and dissolves.
- Build choropleth or interactive maps.
- Combine tabular attributes with geometry.

## Install

```bash
pip install geopandas
pip install pyarrow folium mapclassify contextily matplotlib
```

Optional: install `psycopg2` or `psycopg` plus `geoalchemy2` for PostGIS, and `cartopy` for projections.

## Quick start

```python
import geopandas as gpd

gdf = gpd.read_file('data.geojson')
print(gdf.head())
print(gdf.crs)
print(gdf.geometry.geom_type)

gdf = gdf.to_crs('EPSG:3857')
gdf['area'] = gdf.geometry.area

gdf.plot(column='area', legend=True)
gdf.to_file('output.gpkg')
```

## Data structures

- `GeoDataFrame`: a pandas DataFrame with a geometry column.
- `GeoSeries`: a vector of shapely geometries with spatial methods.
- The default geometry column name is `geometry`.

```python
gdf = gpd.GeoDataFrame(
    df,
    geometry=gpd.points_from_xy(df['lon'], df['lat']),
    crs='EPSG:4326',
)
gdf = gdf.set_geometry('geom')
gdf = gdf.rename_geometry('geometry')
```

Rules:

- Use `gdf.geometry` for spatial operations.
- Keep one active geometry column unless you need several.
- Reset the index after joins when index values matter.

## Read and write data

Read:

```python
gdf = gpd.read_file('data.gpkg', bbox=(xmin, ymin, xmax, ymax))
gdf = gpd.read_file('data.shp', columns=['name', 'geometry'])
gdf = gpd.read_postgis('SELECT * FROM parcels', con=engine, geom_col='geom')
gdf = gpd.read_parquet('data.parquet')
```

Write:

```python
gdf.to_file('out.gpkg', layer='data', index=False)
gdf.to_file('out.shp')
gdf.to_postgis('parcels', con=engine, if_exists='replace', index=False)
gdf.to_parquet('out.parquet', index=False)
```

Rules:

- Prefer GeoPackage or Parquet for modern workflows.
- Shapefile truncates column names to 10 characters and has format limits.
- Filter during read with `bbox`, `mask`, or `columns`.
- Use `use_arrow=True` where supported for faster I/O.

## CRS management

```python
print(gdf.crs)
gdf = gdf.to_crs('EPSG:3857')
gdf = gdf.to_crs(4326)
gdf = gdf.set_crs('EPSG:4326', allow_override=True)  # metadata only
utm_crs = gdf.estimate_utm_crs()
```

Rules:

- Check CRS before every spatial operation.
- Use `to_crs` to transform coordinates.
- Use `set_crs` only when CRS metadata is missing.
- Use a projected CRS for area, length, distance, and buffer.
- Match CRS before joins, overlays, and layered plotting.
- Use `gdf1.crs == gdf2.crs` to check equality.

## Geometry operations

```python
gdf['area'] = gdf.geometry.area
gdf['length'] = gdf.geometry.length
gdf['centroid'] = gdf.geometry.centroid
buffered = gdf.copy()
buffered['geometry'] = gdf.geometry.buffer(100)
simplified = gdf.geometry.simplify(10, preserve_topology=True)
clipped = gpd.clip(gdf, mask_gdf)
gdf['geometry'] = gdf.geometry.make_valid()
exploded = gdf.explode(index_parts=True)
```

Useful methods:

- `centroid`, `convex_hull`, `envelope`, `boundary`
- `distance(other)`, `total_bounds`
- `is_valid`, `is_empty`, `geom_type`
- `translate`, `rotate`, `scale`, `affine_transform`
- `segmentize`, `normalize`

Predicates:

```python
subset = gdf[gdf.geometry.within(boundary)]
combined = other.geometry.union_all()  # use unary_union on older versions
mask = gdf.geometry.intersects(combined)
```

Rules:

- Buffer units are CRS units.
- Simplify tolerance is in CRS units.
- Preserve topology for analysis.
- Filter empty geometries after clip or overlay.
- Validate geometries before spatial operations.

## Spatial analysis

Spatial join:

```python
joined = gpd.sjoin(left, right, how='inner', predicate='intersects')
nearest = gpd.sjoin_nearest(
    left, right, how='left', max_distance=1000, distance_col='distance'
)
```

Overlay:

```python
intersection = gpd.overlay(left, right, how='intersection')
difference = gpd.overlay(left, right, how='difference')
union = gpd.overlay(left, right, how='union')
```

Dissolve:

```python
dissolved = gdf.dissolve(by='region', aggfunc='sum')
dissolved = gdf.dissolve(
    by='region', aggfunc={'population': 'sum', 'area': 'sum'}
)
```

Clip and index:

```python
clipped = gpd.clip(gdf, mask)
hits = list(gdf.sindex.query(geometry, predicate='intersects'))
subset = gdf.cx[xmin:xmax, ymin:ymax]
```

Rules:

- Choose predicate by task: `intersects`, `within`, `contains`, `touches`, `overlaps`.
- Set `max_distance` in nearest joins for performance.
- Use `make_valid=True` in overlay when inputs may be invalid.
- Dissolve changes row count; check the aggregation function.
- Spatial joins add `index_left` and `index_right`.

## Visualization

Static:

```python
gdf.plot(column='value', cmap='viridis', legend=True, figsize=(8, 6))
gdf.plot(column='class', categorical=True, legend=True)
gdf.plot(column='income', scheme='quantiles', k=5, cmap='YlOrRd', legend=True)
```

Interactive:

```python
m = gdf.explore(column='value', tooltip=['name', 'value'], tiles='CartoDB positron')
m.save('map.html')
```

Layers:

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots()
gdf.plot(ax=ax, color='lightgrey', edgecolor='white')
points.plot(ax=ax, color='red', markersize=5)
```

Basemap:

```python
import contextily as ctx

gdf_3857 = gdf.to_crs('EPSG:3857')
ax = gdf_3857.plot()
ctx.add_basemap(ax, crs=gdf_3857.crs, source=ctx.providers.OpenStreetMap.Mapnik)
```

Rules:

- Reproject to Web Mercator for common basemaps.
- Install `mapclassify` for classification schemes.
- Handle missing values in choropleths.
- Interactive maps require `folium`.

## Common workflows

Points from coordinates:

```python
gdf = gpd.GeoDataFrame(
    df, geometry=gpd.points_from_xy(df['lon'], df['lat']), crs='EPSG:4326'
)
```

Load, transform, analyze, export:

```python
gdf = gpd.read_file('data.shp')
gdf = gdf.to_crs('EPSG:3857')
gdf['area'] = gdf.geometry.area
buffered = gdf.copy()
buffered['geometry'] = gdf.geometry.buffer(100)
gdf.to_file('results.gpkg', layer='original')
buffered.to_file('results.gpkg', layer='buffered')
```

Join and aggregate:

```python
joined = gpd.sjoin(points, polygons, predicate='within')
agg = joined.groupby('index_right').agg(value=('value', 'sum'))
result = polygons.merge(agg, left_index=True, right_index=True)
```

Multi-source:

```python
roads = gpd.read_file('roads.shp')
buildings = gpd.read_file('buildings.geojson').to_crs(roads.crs)
near = buildings[buildings.geometry.distance(roads.geometry.union_all()) < 50]
```

## Performance

- Filter during read with `bbox`, `mask`, or `columns`.
- Use Parquet and `use_arrow=True` for faster I/O.
- Simplify geometries when precision is not critical.
- Use vectorized operations instead of row loops.
- Use projected CRS for metric calculations.
- Use spatial index queries for large datasets.
- Explode multipart geometries only when needed.
- Set `max_distance` in nearest joins.

## Best practices

- Always check and match CRS.
- Use projected CRS for area and distance.
- Validate geometries with `is_valid`.
- Use `.copy()` when replacing geometry.
- Use GeoPackage or Parquet instead of Shapefile.
- Preserve topology when simplifying.
- Use `make_valid` before overlay when needed.
- Filter empty geometries after geometric operations.
- Use `max_distance` and spatial predicates deliberately.

## Pitfalls

- `set_crs` changes metadata only; it does not transform coordinates.
- Geographic CRS returns degrees, not meters.
- Invalid geometries can break overlay and joins.
- Shapefile column names are truncated.
- CRS mismatch can produce wrong results without errors.
- `sjoin` can create duplicate rows for many-to-many matches.
- Overlay can produce GeometryCollection or empty geometries.
- Plotting with missing values needs handling.
- Large datasets can consume memory; filter early.

## Checklist

- [ ] CRS checked and matched
- [ ] Projected CRS used for metrics
- [ ] Geometries validated
- [ ] Empty geometries filtered
- [ ] Output format supports attributes and CRS
- [ ] Spatial index or filters used for large data
- [ ] Results inspected before export

## Related skills

Load these when the task spans more than this skill.

- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`data-engineering`](../data-engineering/SKILL.md) — Guides the design, implementation, and operation of scalable batch and streaming data pipelines, modern data w…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`d3-visualization`](../d3-visualization/SKILL.md) — Create custom interactive D3.js visualizations, including charts, graphs, networks, maps, transitions, and SVG…
- [`networkx`](../networkx/SKILL.md) — Create, analyze, and visualize graphs in Python with NetworkX: graph types, algorithms, generators, file I/O,…
