---
name: networkx
description: "Create, analyze, and visualize graphs in Python using NetworkX with support for directed, undirected, multi-graph, and bipartite structures plus algorithms for centrality, shortest paths, community detection, clustering, and generators for random, scale-free, and small-world networks. Use when building network analysis pipelines, computing PageRank betweenness closeness eigenvector centrality, finding shortest paths with Dijkstra A* Bellman-Ford, detecting communities with Louvain Girvan-Newman label propagation, generating synthetic graphs with Erdos-Renyi Barabasi-Albert Watts-Strogatz models, reading writing GraphML GML GEXF edge lists adjacency matrices, or plotting with matplotlib spring circular spectral layouts."
---

# NetworkX

NetworkX is a Python library for creating, manipulating, analyzing, and visualizing graphs and networks. Use it for pairwise relationships, graph algorithms, synthetic networks, graph I/O, and network plots.

## When to use

- Build or modify `Graph`, `DiGraph`, `MultiGraph`, or `MultiDiGraph` objects.
- Compute shortest paths, centrality, clustering, components, communities, flows, matching, or trees.
- Generate synthetic networks for testing, simulation, or modeling.
- Read or write graphs in edge lists, adjacency lists, GraphML, GML, JSON, CSV, Pandas, NumPy, or SciPy formats.
- Visualize networks with matplotlib layouts and customize node, edge, and label appearance.

## Graph types and creation

NetworkX supports four main graph types:

- `Graph`: undirected graph with at most one edge between two nodes.
- `DiGraph`: directed graph with one-way edges.
- `MultiGraph`: undirected graph allowing multiple edges between the same nodes.
- `MultiDiGraph`: directed graph allowing multiple edges between the same nodes.

Create and modify graphs directly:

```python
import networkx as nx

G = nx.Graph()
G.add_node(1)
G.add_nodes_from([2, 3, 4])
G.add_node("protein_A", type="enzyme", weight=1.5)

G.add_edge(1, 2)
G.add_edges_from([(1, 3), (2, 4)])
G.add_edge(1, 4, weight=0.8, relation="interacts")

G.remove_node(1)
G.remove_edge(2, 4)
```

Nodes can be any hashable Python object. Removing a node also removes all incident edges. Inspect structure with:

```python
G.number_of_nodes()
G.number_of_edges()
G.degree(1)
list(G.neighbors(1))
G.has_node(1)
G.has_edge(1, 2)
nx.density(G)
nx.is_connected(G)
```

## Algorithms

Compute common network metrics and structures:

```python
# Shortest paths
path = nx.shortest_path(G, source=1, target=5)
length = nx.shortest_path_length(G, source=1, target=5, weight="weight")
all_paths = nx.all_pairs_shortest_path(G)

# Centrality
degree_cent = nx.degree_centrality(G)
betweenness = nx.betweenness_centrality(G)
closeness = nx.closeness_centrality(G)
pagerank = nx.pagerank(G)

# Clustering
node_clustering = nx.clustering(G)
avg_clustering = nx.average_clustering(G)

# Components
components = list(nx.connected_components(G))
strong_components = list(nx.strongly_connected_components(G))  # DiGraph

# Community detection
from networkx.algorithms import community
communities = community.greedy_modularity_communities(G)
```

For directed graphs, use strongly connected components. For large graphs, use approximate centrality variants with a `k` parameter when available.

## Graph generators

Create synthetic networks for testing or simulation:

```python
# Classic graphs
G = nx.complete_graph(n=10)
G = nx.cycle_graph(n=20)
G = nx.karate_club_graph()
G = nx.petersen_graph()

# Random networks
G = nx.erdos_renyi_graph(n=100, p=0.1, seed=42)
G = nx.barabasi_albert_graph(n=100, m=3, seed=42)
G = nx.watts_strogatz_graph(n=100, k=6, p=0.1, seed=42)

# Structured networks
G = nx.grid_2d_graph(m=5, n=7)
G = nx.random_tree(n=100, seed=42)
```

Set random seeds for reproducible random graphs and layouts.

## Reading and writing graphs

Use the format that matches your data and attribute needs:

```python
# Edge lists
G = nx.read_edgelist("graph.edgelist")
nx.write_edgelist(G, "graph.edgelist")

# GraphML preserves attributes
G = nx.read_graphml("graph.graphml")
nx.write_graphml(G, "graph.graphml")

# GML
G = nx.read_gml("graph.gml")
nx.write_gml(G, "graph.gml")

# JSON node-link data
data = nx.node_link_data(G)
G = nx.node_link_graph(data)
```

Integrate with Pandas, NumPy, and SciPy:

```python
import pandas as pd
import numpy as np

# Pandas
df = pd.DataFrame({"source": [1, 2, 3], "target": [2, 3, 4], "weight": [0.5, 1.0, 0.75]})
G = nx.from_pandas_edgelist(df, "source", "target", edge_attr="weight")
df = nx.to_pandas_edgelist(G)

# NumPy adjacency matrix
A = nx.to_numpy_array(G)
G = nx.from_numpy_array(A)

# SciPy sparse matrix
A = nx.to_scipy_sparse_array(G)
G = nx.from_scipy_sparse_array(A)
```

## Visualization

Draw networks with matplotlib. Compute positions once and reuse them:

```python
import matplotlib.pyplot as plt

pos = nx.spring_layout(G, seed=42)
nx.draw(G, pos=pos, with_labels=True, node_color="lightblue", node_size=500)
plt.show()
```

Customize appearance by degree, centrality, or edge weight:

```python
node_colors = [G.degree(n) for n in G.nodes()]
centrality = nx.betweenness_centrality(G)
node_sizes = [3000 * centrality[n] for n in G.nodes()]
edge_widths = [3 * G[u][v].get("weight", 1) for u, v in G.edges()]

nx.draw(
    G,
    pos=pos,
    node_color=node_colors,
    cmap=plt.cm.viridis,
    node_size=node_sizes,
    width=edge_widths,
)
```

Use layout algorithms such as `spring_layout`, `circular_layout`, `kamada_kawai_layout`, and `spectral_layout`. For publication-quality output:

```python
plt.figure(figsize=(12, 8))
pos = nx.spring_layout(G, seed=42)
nx.draw(G, pos=pos, node_color="lightblue", node_size=500,
        edge_color="gray", with_labels=True, font_size=10)
plt.title("Network Visualization", fontsize=16)
plt.axis("off")
plt.tight_layout()
plt.savefig("network.png", dpi=300, bbox_inches="tight")
plt.savefig("network.pdf", bbox_inches="tight")
```

## Common workflow

1. Create or load a graph.
2. Examine node, edge, density, and connectivity counts.
3. Compute metrics, paths, components, or communities.
4. Visualize with a fixed seed and layout.
5. Export the graph and derived metrics.

```python
G = nx.read_edgelist("data.txt")
print(f"Nodes: {G.number_of_nodes()}")
print(f"Edges: {G.number_of_edges()}")
print(f"Density: {nx.density(G)}")
print(f"Connected: {nx.is_connected(G)}")

degree_cent = nx.degree_centrality(G)
avg_clustering = nx.average_clustering(G)
path = nx.shortest_path(G, source=1, target=4)
communities = community.greedy_modularity_communities(G)

pos = nx.spring_layout(G, seed=42)
nx.draw(G, pos=pos, with_labels=True)
plt.show()

nx.write_graphml(G, "analyzed_network.graphml")
```

## Important considerations

- Floating-point graph values produce approximate results, especially in minimum or maximum computations.
- Large graphs require memory-aware handling: use sparse matrices, load only needed subgraphs, and use efficient formats.
- Use approximate algorithms for very large networks when available.
- Nodes can be any hashable Python object; use meaningful identifiers.
- Set random seeds for reproducible random generation and force-directed layouts.
- Install NetworkX with `pip install networkx` or `uv pip install networkx`; use `networkx[default]` for optional dependencies.

## Checklist

- [ ] Choose the correct graph type for direction and multiplicity.
- [ ] Add nodes and edges with useful attributes.
- [ ] Verify connectivity and basic counts before analysis.
- [ ] Use weighted parameters consistently in path and centrality calls.
- [ ] Set random seeds for generators and layouts.
- [ ] Export both the graph and computed metrics.
- [ ] Save figures with sufficient DPI or vector format for publication.

## Related skills

Load these when the task spans more than this skill.

- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`scikit-learn`](../scikit-learn/SKILL.md) — Build, evaluate, and tune classical machine learning models with scikit-learn: classification, regression, clu…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`geopandas`](../geopandas/SKILL.md) — Use GeoPandas to read, transform, analyze, and map vector geospatial data in formats such as Shapefile, GeoJSO…
