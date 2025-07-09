#!/usr/bin/env python3
import os
from dotenv import load_dotenv
import yaml

load_dotenv(".env")

jwt = os.getenv("JWT_TOKEN", "").strip()
bearer = os.getenv("BEARER_TOKEN", "").strip()

if not jwt:
    raise ValueError("Missing JWT_TOKEN in .env")

config = {
    "tokens": [{
        "jwt": jwt,
        "bearer": bearer or ""
    }]
}

with open("config.yaml", "w") as f:
    yaml.dump(config, f)

print("✅ Wrote config.yaml based on .env")

