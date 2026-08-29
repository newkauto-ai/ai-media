# Series Visual Resolver

Resolve each visual field independently:

1. current platform hard spec for dimensions, format, file size, and safe zone;
2. a `ready` Series variant compatible with the platform/aspect ratio;
3. episode-specific title and visual signal;
4. conservative field fallback.

Only explicit approved exceptions may replace a Series field. Record `field_sources` and unresolved conflicts. Never apply a generic template over a compatible complete Series variant.
