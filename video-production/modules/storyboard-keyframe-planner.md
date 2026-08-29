# Storyboard and Keyframe Planner

Storyboard validates spatial and action feasibility rather than requiring a full image for every Shot. It is optional for low risk, recommended for medium risk, and required for high-risk multi-character blocking, fast action, complex space, high-energy multi-shot plans, or important transitions.

Use First Frame, End Frame, Transition Frame, and Continuity Resume Frame only where they reduce a named risk. A Resume Keyframe inherits inspected `actual_end_state`, not the ideal ADP state.

`Scene Setting` is a plot-free spatial baseline for topology, fixed objects, and coverage. `Key Frame` is a story/action reference. `Resume Frame` is a continuity reference derived from the ledger's observed state. These roles are not interchangeable and a Fixture never upgrades one role into another.
