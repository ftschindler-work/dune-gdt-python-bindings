from dune.xt.grid import AllDirichletBoundaryInfo, Dim, Walker
from dune.xt.functions import GridFunction as GF

from dune.gdt import (
    ContinuousLagrangeSpace,
    DirichletConstraints,
    DiscreteFunction,
    LocalElementIntegralBilinearForm,
    LocalElementIntegralFunctional,
    LocalElementProductIntegrand,
    LocalLaplaceIntegrand,
    MatrixOperator,
    VectorFunctional,
    make_element_sparsity_pattern,
)


def discretize_elliptic_cg_dirichlet_zero(grid, diffusion, source):

    """
    Discretizes the stationary heat equation with homogeneous Dirichlet boundary values everywhere
    with dune-gdt using continuous Lagrange finite elements.

    Parameters
    ----------
    grid
        The grid, given as a GridProvider from dune.xt.grid.
    diffusion
        Diffusion function with values in R^{d x d}, anything that dune.xt.functions.GridFunction
        can handle.
    source
        Right hand side source function with values in R, anything that
        dune.xt.functions.GridFunction can handle.
    
    Returns
    -------
    u_h
        The computed solution as a dune.gdt.DiscreteFunction for postprocessing.
    """
    
    d = grid.dimension
    diffusion = GF(grid, diffusion, dim_range=(Dim(d), Dim(d)))
    source = GF(grid, source)

    boundary_info = AllDirichletBoundaryInfo(grid)
    
    V_h = ContinuousLagrangeSpace(grid, order=1)

    l_h = VectorFunctional(grid, source_space=V_h)
    l_h += LocalElementIntegralFunctional(LocalElementProductIntegrand(GF(grid, 1)).with_ansatz(source))
    
    a_h = MatrixOperator(grid, source_space=V_h, range_space=V_h,
                         sparsity_pattern=make_element_sparsity_pattern(V_h))
    a_h += LocalElementIntegralBilinearForm(LocalLaplaceIntegrand(diffusion))
    
    dirichlet_constraints = DirichletConstraints(boundary_info, V_h)
    
    walker = Walker(grid)
    walker.append(a_h)
    walker.append(l_h)
    walker.append(dirichlet_constraints)
    walker.walk()
    
    u_h = DiscreteFunction(V_h, name='u_h')
    dirichlet_constraints.apply(a_h.matrix, l_h.vector)
    a_h.apply_inverse(l_h.vector, u_h.dofs.vector)
    
    return u_h
