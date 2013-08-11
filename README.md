clusterfan
==========

Cluster algebras seeds calculations

Calculates seeds of cluster algebras (see works of G. Koshevoy, B. Keller, B. Leclerc).

At this point this is proof of concept.

Calculates number of seeds (cones in fan) of cluster algebra (for n=5 the answer is 672).
Calculates number of distinct tabloids (generating elements) of cluster algebra( (for n=5 the answer is 36).

Optimized n^2 algorithm with hash comparison and lazy rehash.

Created script for pretty presentations of graphs uging GraphViz. 
Still in development, now only example, with hardcoded path of mutations

TODO:
- Create presentation for association graph.
- Calculation for n=6,finding limit of imaginary elements.
