import importlib.util
import json
import sys
from pathlib import Path


runtime_path = Path(sys.argv[1]).resolve()
fixture_path = Path(sys.argv[2]).resolve()
spec = importlib.util.spec_from_file_location("skill5_runtime", runtime_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

fixture = json.loads(fixture_path.read_text(encoding="utf-8-sig"))
target_hash = "A" * 64
cover = {"composed_asset_checksum_sha256": target_hash}
results = []
for case in fixture["cases"]:
    supplied = {
        "target_cover_hash": target_hash,
        "evidence_source": "evaluator",
        "findings": [{"code": case["case_id"], "content_id": fixture["content_id"]}],
        **case["review"],
    }
    input_data = {"review_inputs": {"cover_semantic_review_by_platform": {"xiaohongshu": supplied}}}
    result = module.cover_semantic_review(input_data, "xiaohongshu", cover)
    assert result["verdict"] == case["expected"], case["case_id"]
    assert result["verdict"] != "pass", case["case_id"]
    results.append({"case_id": case["case_id"], "verdict": result["verdict"]})

print(json.dumps({"content_id": fixture["content_id"], "cases": results, "retry_budget_consumed": 0}, ensure_ascii=False))
