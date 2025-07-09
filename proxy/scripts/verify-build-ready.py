#!/usr/bin/env python3

import os
import sys
import yaml

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "..", "config.yaml")
DOCKERFILE_PATH = os.path.join(os.path.dirname(__file__), "..", "Dockerfile")

def fail(msg):
    print(f"❌ {msg}")
    sys.exit(1)

def check_config():
    if not os.path.exists(CONFIG_PATH):
        fail("Missing config.yaml. Make sure it's next to the Dockerfile in /proxy.")

    with open(CONFIG_PATH) as f:
        try:
            data = yaml.safe_load(f)
            if not isinstance(data, dict) or "tokens" not in data:
                fail("config.yaml does not contain a 'tokens' field.")
            if not data["tokens"] or "jwt" not in data["tokens"][0]:
                fail("config.yaml must contain at least one jwt token.")
        except Exception as e:
            fail(f"Error parsing config.yaml: {str(e)}")
    print("✅ config.yaml is present and valid.")

def check_dockerfile():
    if not os.path.exists(DOCKERFILE_PATH):
        fail("Missing Dockerfile.")
    with open(DOCKERFILE_PATH) as f:
        if "COPY config.yaml" not in f.read():
            print("⚠️ Warning: Dockerfile may be missing 'COPY config.yaml'.")
        else:
            print("✅ Dockerfile includes COPY statement.")

if __name__ == "__main__":
    print("🔍 Verifying build readiness...\n")
    check_config()
    check_dockerfile()
    print("\n🚀 Ready to build!")

