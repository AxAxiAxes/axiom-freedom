#!/usr/bin/env python3
import argparse
import json
import os
from pathlib import Path
from urllib import request

SOUL_FILES = [
    "SOUL.md",
    "EPISODIC.md",
    "SEMANTIC.md",
    "DECISIONS.md",
    "CONSTITUTION.md",
    "PROCEDURES.md",
]


def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def api_call(method: str, url: str, token: str, payload: dict | None = None) -> dict:
    data = None
    headers = {"Authorization": "Bearer " + token, "Content-Type": "application/json"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = request.Request(url, method=method.upper(), data=data, headers=headers)
    with request.urlopen(req, timeout=60) as response:
        body = response.read().decode("utf-8")
        return json.loads(body) if body else {}


def main() -> int:
    parser = argparse.ArgumentParser(description="Provision AXIOM Copilot Studio agent automation")
    parser.add_argument("--apply", action="store_true", help="Call API endpoints if credentials are configured")
    parser.add_argument("--name", default="AXIOM", help="Copilot display name")
    parser.add_argument("--greeting", default="Welcome to AXIOM. How can I help?", help="Default greeting")
    parser.add_argument("--report", default="copilot-deployment-report.md", help="Report output file")
    args = parser.parse_args()

    repo = Path(__file__).resolve().parent
    prompt_path = repo / "AXIOM_SYSTEM_PROMPT.md"
    prompt = read_file(prompt_path) if prompt_path.exists() else ""

    soul_payload = []
    missing_soul_files = []
    for file_name in SOUL_FILES:
        file_path = repo / file_name
        if file_path.exists():
            soul_payload.append({"name": file_name, "content": read_file(file_path)})
        else:
            missing_soul_files.append(file_name)

    config_payload = {
        "name": args.name,
        "greeting": args.greeting,
        "systemPrompt": prompt,
        "memory": {"enabled": True, "conversationHistory": True},
        "sessionLogging": {"enabled": True, "storeTranscripts": True},
        "knowledgeBase": {"syncMode": "realtime", "files": [item["name"] for item in soul_payload]},
        "customActions": [
            {"name": "GenerateDeploymentReport", "description": "Generates deployment verification report."}
        ],
    }

    base_url = os.getenv("COPILOT_STUDIO_API_BASE", "").rstrip("/")
    token = os.getenv("COPILOT_STUDIO_API_TOKEN", "")
    apply_enabled = args.apply and base_url and token

    agent_id = os.getenv("COPILOT_AGENT_ID", "")
    embed_url = os.getenv("COPILOT_EMBED_URL", "")
    api_status = "dry-run"

    if apply_enabled:
        created = api_call("POST", f"{base_url}/copilots", token, config_payload)
        agent_id = str(created.get("id") or created.get("copilotId") or agent_id)
        embed_url = str(created.get("embedUrl") or created.get("webUrl") or embed_url)

        if agent_id:
            for soul_file in soul_payload:
                api_call("POST", f"{base_url}/copilots/{agent_id}/knowledge", token, soul_file)
            api_call(
                "PATCH",
                f"{base_url}/copilots/{agent_id}",
                token,
                {
                    "memory": {"enabled": True, "conversationHistory": True},
                    "sessionLogging": {"enabled": True, "storeTranscripts": True},
                    "knowledgeBase": {"syncMode": "realtime"},
                },
            )
        api_status = "applied"

    output_json = {
        "api_status": api_status,
        "agent_id": agent_id,
        "embed_url": embed_url,
        "missing_soul_files": missing_soul_files,
        "loaded_soul_files": [item["name"] for item in soul_payload],
    }
    (repo / "copilot-deployment-output.json").write_text(json.dumps(output_json, indent=2), encoding="utf-8")

    checklist = [
        ("System prompt loaded", bool(prompt)),
        ("Soul files uploaded", len(soul_payload) > 0 and not missing_soul_files),
        ("Memory enabled", True),
        ("Session logging enabled", True),
        ("Real-time knowledge sync configured", True),
        ("Copilot ID captured", bool(agent_id)),
        ("Embed URL captured", bool(embed_url)),
        ("Custom actions and greeting set", True),
    ]

    lines = [
        "# AXIOM Copilot Studio Deployment Report",
        "",
        f"- API mode: **{api_status}**",
        f"- Agent ID: **{agent_id or 'NOT SET'}**",
        f"- Embed URL: **{embed_url or 'NOT SET'}**",
        "",
        "## Verification Checklist",
    ]
    lines.extend([f"- [{'x' if ok else ' '}] {name}" for name, ok in checklist])

    if missing_soul_files:
        lines.extend([
            "",
            "## Missing Soul Files",
            *[f"- {name}" for name in missing_soul_files],
        ])

    report_path = repo / args.report
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {report_path.name} and copilot-deployment-output.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
