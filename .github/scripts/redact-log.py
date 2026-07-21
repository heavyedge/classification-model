#!/usr/bin/env python3

import argparse
import os
import re
from pathlib import Path

parser = argparse.ArgumentParser(description="Redact log file.")
parser.add_argument("input_file", type=Path)
parser.add_argument("output_file", type=Path)
parser.add_argument(
    "--template-file",
    type=Path,
    required=True,
    help="Template file whose ${NAME} variables are used to discover secrets.",
)
args = parser.parse_args()

content = args.input_file.read_text(encoding="utf-8", errors="replace")
template_names = set()
template = args.template_file.read_text(encoding="utf-8", errors="replace")
template_names = set(re.findall(r"\$\{([A-Z_][A-Z0-9_]*)\}", template))

missing_names = sorted(name for name in template_names if name not in os.environ)
if missing_names:
    print(
        "WARNING: refusing to redact log because these template variables "
        f"are missing from the environment: {', '.join(missing_names)}"
    )
    raise SystemExit(2)

secrets = sorted(
    {os.environ[name] for name in template_names},
    key=len,
    reverse=True,
)
for secret in secrets:
    content = content.replace(secret, "[REDACTED]")

args.output_file.write_text(content, encoding="utf-8")
