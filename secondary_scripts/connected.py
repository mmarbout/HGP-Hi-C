#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import scipy.sparse as sparse
import sys
from scipy.sparse.csgraph import connected_components

mat = np.loadtxt(sys.argv[1], dtype=np.int32)

sparse = sparse.coo_matrix((mat[:,2],(mat[:,0],mat[:,1])))
dense = sparse.todense()
mat2=np.asarray(dense)

a=connected_components(mat2,directed=False)
np.savetxt(sys.argv[2], a[1], fmt="%1.0f")
