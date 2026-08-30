import importlib.util
import json
import sys
from pathlib import Path


runtime_path = Path(sys.argv[1]).resolve()
spec = importlib.util.spec_from_file_location("skill5_runtime", runtime_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

binding = {"final_qa_status": "accepted", "cover_prompt_only": False}
packaged_copy = {"title_or_caption": "具体标题", "body_or_description": "场景、核心承诺与受众收益。", "length_findings": []}
cover = {"composed_asset_path": None, "qa": {"overall": "blocked", "blocking_reasons": ["cover_asset_not_ready"]}}
snapshot = {"critical_rules_status": "current"}
safety = {"fixture_only": False, "shadow_only": False}


def result(review):
    return module.readiness(binding, [], False, "xiaohongshu", packaged_copy, cover, snapshot, review, safety)


unresolved = result({"promise_match": "human_review", "metadata_relevance": "human_review", "evidence_refs": ["review:pending"]})
assert unresolved["status"] == "PACKAGE_DRAFT"
assert {"promise_match_unresolved", "metadata_relevance_unresolved"}.issubset(unresolved["blocking_reasons"])

missing_evidence = result({"promise_match": "pass", "metadata_relevance": "pass", "evidence_refs": []})
assert missing_evidence["status"] == "PACKAGE_DRAFT"
assert "editorial_evidence_missing" in missing_evidence["blocking_reasons"]

passed = result({"promise_match": "pass", "metadata_relevance": "pass", "evidence_refs": ["review:thesis-first"]})
assert passed["status"] == "COPY_READY"

print(json.dumps({"unresolved": "PACKAGE_DRAFT", "missing_evidence": "PACKAGE_DRAFT", "passed": "COPY_READY"}))
