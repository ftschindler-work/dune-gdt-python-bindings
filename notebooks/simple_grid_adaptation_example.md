---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.5.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---

```python
# wurlitzer: display dune's output in the notebook
%load_ext wurlitzer
%matplotlib notebook
```

```python
import numpy as np

from dune.xt.common.vtk.plot import plot as k3d_plot
from dune.xt.grid import Dim, Simplex, make_cube_grid

grid = make_cube_grid(Dim(2), Simplex(), [-1, -1], [1, 1], [1, 1])
grid.visualize('grid_0')
_ = k3d_plot('grid_0.vtu', color_attribute_name='Element index')

# we require one global refinement for simlexgrids to obtain a symmetric grid
grid.global_refine(1)

print(f'grid has {grid.size(0)} elements')

grid.visualize('grid_1')
_ = k3d_plot('grid_1.vtu', color_attribute_name='Element index')
```

```python
from dune.gdt import ContinuousLagrangeSpace, DiscreteFunction, AdaptationHelper

V_h = ContinuousLagrangeSpace(grid, order=1)
u_h = DiscreteFunction(V_h, name='u_h')

print(f'space has {V_h.num_DoFs} DoFs')
```

```python
adaptation_helper = AdaptationHelper(grid)
adaptation_helper.append(V_h, u_h)
```

```python
markers = np.array(adaptation_helper.markers, copy=False) # direct access to dune vector without copy
centers = np.array(grid.centers(0), copy=False)

elements_in_the_left_half = np.where(centers[:, 0] < 0)[0]
markers[elements_in_the_left_half] = 1
adaptation_helper.mark()
```

```python
adaptation_helper.pre_adapt()
adaptation_helper.adapt()
adaptation_helper.post_adapt()
```

```python
print(f'grid has {grid.size(0)} elements')

grid.visualize('grid_2')
_ = k3d_plot('grid_2.vtu', color_attribute_name='Element index')

print(f'space has {V_h.num_DoFs} DoFs')
```
