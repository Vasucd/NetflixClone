#!/bin/bash
# Script to trigger the Bug Claude Direct workflow

# Set -e to exit on error
set -e

# Print banner
echo "========================================"
echo "🧠 Claude Bug Analyzer"
echo "========================================"

# Check if required arguments are provided
if [ "$#" -lt 3 ]; then
  echo "❌ Error: Missing required arguments"
  echo ""
  echo "Usage: $0 <github_token> <title> <description>"
  echo "Example: $0 ghp_abc123 'App crashes on startup' 'When I open the app, it shows a white screen and crashes'"
  echo ""
  echo "Token requirements:"
  echo "- Must have 'repo' scope for accessing the repository"
  echo "- Must have 'workflow' scope for triggering workflows"
  exit 1
fi

# Assign arguments to variables
GITHUB_TOKEN="$1"
TITLE="$2"
DESCRIPTION="$3"

# GitHub repository details
OWNER="Vasucd"
REPO="NetflixClone"

# Verify token first
echo "🔐 Checking GitHub token validity..."
TOKEN_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user")

if [ "$TOKEN_CHECK" = "401" ]; then
  echo "❌ Error: Invalid GitHub token"
  exit 1
elif [ "$TOKEN_CHECK" != "200" ]; then
  echo "⚠️ Warning: GitHub API returned code $TOKEN_CHECK"
fi

# Display information
echo "📣 Sending bug to Claude for analysis:"
echo "  Repository: $OWNER/$REPO"
echo "  Event type: claude-bug-analysis"
echo "  Title: $TITLE"
echo "  Description: ${DESCRIPTION:0:50}..."

# Create temp file for JSON payload to avoid issues with shell escaping
JSON_FILE=$(mktemp)
cat > "$JSON_FILE" << EOF
{
  "event_type": "claude-bug-analysis",
  "client_payload": {
    "title": "$TITLE",
    "description": "$DESCRIPTION"
  }
}
EOF

# Send the request to the GitHub API with better error handling
echo "📤 Sending request to GitHub API..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/$OWNER/$REPO/dispatches" \
  -d @"$JSON_FILE")

# Clean up temp file
rm "$JSON_FILE"

# Get status code from last line
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
# Get response body (all but the last line)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Check response
if [ "$HTTP_STATUS" = "204" ]; then
  echo "✅ Success! Bug sent to Claude for analysis."
  echo "👀 The workflow will:"
  echo "  1. Create an issue with your bug details"
  echo "  2. Ask Claude to analyze the bug"
  echo "  3. Post Claude's analysis as a comment on the issue"
  echo ""
  echo "Check the GitHub Actions tab for workflow runs:"
  echo "    https://github.com/$OWNER/$REPO/actions"
  echo ""
  echo "And the Issues tab for Claude's analysis (may take a minute):"
  echo "    https://github.com/$OWNER/$REPO/issues"
else
  echo "❌ Error: GitHub API returned status code $HTTP_STATUS"
  echo "Response: $RESPONSE_BODY"
  
  if [ "$HTTP_STATUS" = "403" ]; then
    echo ""
    echo "🔒 This is likely a permissions issue. Your token needs:"
    echo "  1. 'repo' scope for accessing this repository"
    echo "  2. 'workflow' scope for triggering workflows"
    echo ""
    echo "Try generating a new token with the correct permissions:"
    echo "https://github.com/settings/tokens/new?scopes=repo,workflow"
  fi
  
  exit 1
fi