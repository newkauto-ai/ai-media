import importlib.util
import json
import sys
from pathlib import Path


runtime_path = Path(sys.argv[1]).resolve()
package_path = Path(sys.argv[2]).resolve()
spec = importlib.util.spec_from_file_location("skill5_runtime", runtime_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)
package = json.loads(package_path.read_text(encoding="utf-8-sig"))

full_schema = {
    "Name": "title", "Platform": "select", "项目": "relation", "阶段": "select",
    "投影键": "rich_text", "Package Hash": "rich_text", "准备状态": "select",
    "发布日期": "date", "链接": "url", "播放": "number", "决策": "select",
}
base = {
    "captured_at": "2026-08-29T17:00:00+08:00",
    "publishing_data_source_url": "collection://publish",
    "publishing_schema": full_schema,
    "target_project": {"url": "https://app.notion.com/project-rainy", "name": "《雨停之前》"},
    "publishing_rows": [],
    "attachment_capability": {"local_binary_upload_callable": False},
}
key = f"{package['identity']['project_id']}:{package['identity']['content_id']}:{package['identity']['platform']}"
label = module.PLATFORM_LABELS[package["identity"]["platform"]]

create = module.build_notion_projection(package, base)
assert create["row_decision"] == "CREATE" and create["execution_status"] == "CANDIDATE"
required_sections = (
    "## Publish Package Snapshot", "### Package", "### Source Binding", "### 文案", "### Cover Prompt",
    "### 封面", "### 发布窗口", "### Review & Gate", "### Manual Upload", "### Projection History",
    "Body:", "Topics / Hashtags:", "Metadata Relevance:", "Editorial Evidence:",
)
assert all(section in create["page_body_snapshot"] for section in required_sections)
assert "Generated At:" not in create["page_body_snapshot"]

same_row = {"url": "row-1", "投影键": key, "Package Hash": package["package_hash"], "项目": [base["target_project"]["url"]], "Platform": label, "snapshot_heading_count": 1, "managed_snapshot_body": create["page_body_snapshot"]}
no_change = module.build_notion_projection(package, {**base, "publishing_rows": [same_row]})
assert no_change["row_decision"] == "NO_CHANGE" and no_change["execution_status"] == "NO_CHANGE"

body_drift = module.build_notion_projection(package, {**base, "publishing_rows": [{**same_row, "managed_snapshot_body": create["page_body_snapshot"] + "\nmanual drift"}]})
assert body_drift["row_decision"] == "UPDATE" and body_drift["execution_status"] == "DEGRADED"
assert "managed_snapshot_mismatch" in body_drift["blocking_reasons"]

body_unknown = module.build_notion_projection(package, {**base, "publishing_rows": [{key: value for key, value in same_row.items() if key != "managed_snapshot_body"}]})
assert body_unknown["row_decision"] == "UPDATE" and body_unknown["execution_status"] == "DEGRADED"
assert "managed_snapshot_unavailable" in body_unknown["blocking_reasons"]

changed = module.build_notion_projection(package, {**base, "publishing_rows": [{**same_row, "Package Hash": "B" * 64}]})
assert changed["row_decision"] == "UPDATE" and changed["execution_status"] == "CANDIDATE"

duplicate = module.build_notion_projection(package, {**base, "publishing_rows": [same_row, {**same_row, "url": "row-2"}]})
assert duplicate["row_decision"] == "CONFLICT" and duplicate["execution_status"] == "HOLD"

missing_schema = {**base, "publishing_schema": {key: value for key, value in full_schema.items() if key not in {"阶段", "投影键", "Package Hash", "准备状态"}}}
degraded = module.build_notion_projection(package, missing_schema)
assert degraded["row_decision"] == "CREATE" and degraded["execution_status"] == "DEGRADED" and len(degraded["missing_schema_delta"]) == 4

relation_mismatch = module.build_notion_projection(package, {**base, "publishing_rows": [{**same_row, "项目": ["https://app.notion.com/other"]}]})
assert relation_mismatch["row_decision"] == "CONFLICT"

multiple_headings = module.build_notion_projection(package, {**base, "publishing_rows": [{**same_row, "snapshot_heading_count": 2}]})
assert multiple_headings["row_decision"] == "CONFLICT"

readback_mismatch = module.build_notion_projection(package, {**base, "publishing_rows": [{**same_row, "Package Hash": "B" * 64, "simulated_readback_matches": False}]})
assert readback_mismatch["row_decision"] == "UPDATE" and readback_mismatch["execution_status"] == "DEGRADED"

assert set(create["properties_candidate"]) == {"Name", "Platform", "项目", "阶段", "投影键", "Package Hash", "准备状态"}
assert create["attachment"]["status"] == "degraded_local_binary_upload_unavailable"
assert create["external_action_audit"]["notion_write"] == 0 and create["external_action_audit"]["upload"] == 0
print(json.dumps({"create": "CREATE", "same_hash_and_body": "NO_CHANGE", "body_drift": "DEGRADED", "body_unknown": "DEGRADED", "changed_hash": "UPDATE", "duplicate": "CONFLICT", "schema_missing": "DEGRADED", "readback_mismatch": "DEGRADED"}))
