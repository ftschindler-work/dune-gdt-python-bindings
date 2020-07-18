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

# 1: creating a gmsh file

We use pyMORs `PolygonalDomain`description and `discretize_gmsh` to obtain a grid file that `gmsh` can read.

```python
import numpy as np
```

```python
from pymor.analyticalproblems.domaindescriptions import PolygonalDomain

L_shaped_domain = PolygonalDomain(points=[
    [0, 0],
    [0, 1],
    [-1, 1],
    [-1, -1],
    [1, -1],
    [1, 0],
], boundary_types={'dirichlet': [1, 2, 3, 4, 5, 6]})
```

```python
from pymor.discretizers.builtin.domaindiscretizers.gmsh import discretize_gmsh

grid, bi = discretize_gmsh(L_shaped_domain, msh_file_path='L_shaped_domain.msh')
```

# 2: discretization using pyMOR

We may use pyMOR to solve an elliptic PDE on this grid.

```python
from pymor.analyticalproblems.functions import ConstantFunction
from pymor.analyticalproblems.elliptic import StationaryProblem

problem = StationaryProblem(
    domain=L_shaped_domain,
    rhs=ConstantFunction(1, dim_domain=2),
    diffusion=ConstantFunction(1, dim_domain=2),
)
```

```python
from pymor.discretizers.builtin import discretize_stationary_cg

fom, fom_data = discretize_stationary_cg(problem, grid=grid, boundary_info=bi)
```

```python
fom.visualize(fom.solve())
```

# 3: discretization using dune-gdt

`dune-grid` [only supports](https://gitlab.dune-project.org/core/dune-grid/issues/85) `gmsh` version 2 files, but we use `gmsh` version 4. Conversion is achieved by starting the `gmsh` gui, opening the `.msh` file and exporting the mesh to `Version 2 ASCII` (check the *Save all Elements* box!). Afterwards, we need to edit the resulting file and remove all lines between and including `$PhysicalNames` and `$EndPhysicalNames`.

```python
from dune.xt.grid import make_gmsh_grid, Dim, Simplex

grid = make_gmsh_grid('L_shaped_domain_v2.msh', Dim(2), Simplex())
```

```python
from dune.xt.la import Istl

from dune.gdt import ContinuousLagrangeSpace, DiscreteFunction

space = ContinuousLagrangeSpace(grid, order=1)

df = DiscreteFunction(space, Istl())
u = np.array(df.dofs.vector, copy=False)
u[:] = np.ones(len(u))
del u
df.visualize('grid')
```
