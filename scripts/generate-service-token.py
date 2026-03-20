#!/usr/bin/env python3
"""Generate a long-lived JWT token with SERVICE role for inter-service auth."""

import json
import sys
import hmac
import hashlib
import base64
import time

def b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("utf-8")

def generate_jwt(secret: str, kid: str, role: str = "SERVICE", exp_days: int = 3650) -> str:
    """Generate a JWT token signed with HMAC-SHA256."""
    header = {
        "alg": "HS256",
        "typ": "JWT",
        "kid": kid,
    }

    payload = {
        "roles": [role],
        "iss": "5e1b1154-2a69-438c-8b17-20bb8f4deb74",
        "name": "Service",
        "avatar_url": None,
        "iat": int(time.time()),
        "exp": int(time.time()) + (exp_days * 86400),
    }

    header_b64 = b64url_encode(json.dumps(header, separators=(",", ":")).encode())
    payload_b64 = b64url_encode(json.dumps(payload, separators=(",", ":")).encode())

    signing_input = f"{header_b64}.{payload_b64}"
    signature = hmac.new(
        secret.encode(), signing_input.encode(), hashlib.sha256
    ).digest()
    signature_b64 = b64url_encode(signature)

    return f"{header_b64}.{payload_b64}.{signature_b64}"


def main():
    # Default values from vault.yml
    jwt_secret_keys_str = '{"prod_kid": {"kid": "prod_kid", "secret": "3ecc8f19c35da2466122c8af29685dfa1face0a7140ce7cc8c52cf86c5248e25", "valid": true}}'

    if len(sys.argv) > 1:
        jwt_secret_keys_str = sys.argv[1]

    jwt_secret_keys = json.loads(jwt_secret_keys_str)

    # Find first valid key
    for key_id, key_data in jwt_secret_keys.items():
        if key_data.get("valid", False):
            kid = key_data["kid"]
            secret = key_data["secret"]
            token = generate_jwt(secret=secret, kid=kid, role="SERVICE")
            print(f"Generated SERVICE token (kid={kid}):")
            print(token)
            return

    print("ERROR: No valid key found in JWT_SECRET_KEYS", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
