import importlib.util
import json
import sys
from pathlib import Path


runtime_path = Path(sys.argv[1]).resolve()
video_path = Path(sys.argv[2]).resolve()
keyframe_path = Path(sys.argv[3]).resolve()
spec = importlib.util.spec_from_file_location("skill5_runtime", runtime_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

binding = {
    "artifact_path": str(video_path),
    "artifact_version": "v1",
    "source_kind": "video",
    "duration_seconds": 0.0,
}
keyframe_hash = module.sha256_file(keyframe_path)
input_data = {
    "cover_sources": {
        "approved_keyframes": [
            {
                "path": str(keyframe_path),
                "checksum_sha256": keyframe_hash,
                "approval_status": "approved",
                "approval_evidence_ref": "fixture:human-approved-keyframe",
                "compatible_artifact_version": "v1",
                "rights_provenance_ref": "fixture:self-created",
            }
        ],
        "supplied_assets": [],
        "generated_background_fallback": {},
    }
}
selected = module.choose_cover_source(input_data, binding, keyframe_path.parent, keyframe_path.parent / "fallback-output")
assert selected["source_type"] == "approved_visual_reference"
assert selected["source_checksum_sha256"] == keyframe_hash
assert selected["attempts"][0]["route"] == "approved_visual_reference"
assert selected["attempts"][0]["status"] == "selected"

missing = module.choose_cover_source({"cover_sources": {}}, binding, keyframe_path.parent, keyframe_path.parent / "missing-output")
assert missing["source_type"] == "generated_background"
assert missing["source_ref"] == ""
assert missing["attempts"][-1]["status"] == "not_called"
print(json.dumps({"priority": "approved_keyframe_before_optional_final_frame", "generated_background_model_calls": 0}))
