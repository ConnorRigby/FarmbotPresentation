#!/bin/bash
curl -d \
  '{"user":{"email":"email","password":"password"}}' \
  -H "Content-Type:application/json" \
  -X POST https://staging.farmbot.io/api/tokens \
  -s | jq .token.encoded