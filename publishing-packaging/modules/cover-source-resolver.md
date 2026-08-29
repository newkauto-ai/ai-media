# Cover Source Resolver

Use the first available valid route:

1. use an approved dedicated cover asset with a current checksum;
2. use compatible approved Key Frames, Scene Setting Images, and character references;
3. compile a `cover_prompt_package` from those approved references;
4. use a supplied rights-cleared local asset;
5. consider a final-video extracted frame as an optional candidate.

The prompt route never invokes a provider. Without separate generation authorization and an actual returned file, keep `PACKAGE_DRAFT`. Final-video availability must not override an approved dedicated cover or approved Key Frame. Frame scoring is only a technical heuristic and cannot grant semantic approval.
