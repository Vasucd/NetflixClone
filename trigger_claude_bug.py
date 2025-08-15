#!/usr/bin/env python3
"""
Script to trigger the Bug Claude Direct workflow via GitHub API
for automated bug analysis with Claude AI
"""

import argparse
import json
import requests
import sys
import textwrap
try:
    from colorama import init, Fore, Style
    colorama_available = True
except ImportError:
    colorama_available = False
    print("For colored output, install colorama: pip install colorama")

# Initialize colorama if available
if colorama_available:
    init()

def print_colored(text, color=None, bold=False):
    """Print colored text if colorama is available"""
    if colorama_available:
        style = Style.BRIGHT if bold else ""
        color = color or ""
        print(f"{style}{color}{text}{Style.RESET_ALL}")
    else:
        print(text)

def check_token(token):
    """Verify GitHub token validity"""
    print_colored("🔐 Checking GitHub token validity...", Fore.BLUE if colorama_available else None)
    
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    try:
        response = requests.get("https://api.github.com/user", headers=headers)
        if response.status_code == 401:
            print_colored("❌ Error: Invalid GitHub token", Fore.RED if colorama_available else None, bold=True)
            return False
        elif response.status_code != 200:
            print_colored(f"⚠️ Warning: GitHub API returned code {response.status_code}", 
                        Fore.YELLOW if colorama_available else None)
        else:
            user = response.json()
            print_colored(f"✅ Token valid for user: {user.get('login')}", 
                        Fore.GREEN if colorama_available else None)
        return True
    except Exception as e:
        print_colored(f"❌ Error checking token: {e}", Fore.RED if colorama_available else None)
        return False

def trigger_claude_analysis(token, title, description):
    """Trigger the Bug Claude Direct workflow with the provided title and description"""
    
    # GitHub repository details
    owner = "Vasucd"
    repo = "NetflixClone"
    
    # API endpoint
    url = f"https://api.github.com/repos/{owner}/{repo}/dispatches"
    
    # Headers
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "Authorization": f"token {token}",
        "Content-Type": "application/json"
    }
    
    # Payload
    payload = {
        "event_type": "claude-bug-analysis",
        "client_payload": {
            "title": title,
            "description": description
        }
    }
    
    # Display information
    print_colored("📣 Sending bug to Claude for analysis:", Fore.BLUE if colorama_available else None)
    print(f"  Repository: {owner}/{repo}")
    print(f"  Event type: claude-bug-analysis")
    print(f"  Title: {title}")
    print(f"  Description: {description[:50]}..." if len(description) > 50 else f"  Description: {description}")
    
    # Send request
    print_colored("📤 Sending request to GitHub API...", Fore.BLUE if colorama_available else None)
    try:
        response = requests.post(url, headers=headers, json=payload)
        
        # Check response
        if response.status_code == 204:
            print_colored("✅ Success! Bug sent to Claude for analysis.", 
                        Fore.GREEN if colorama_available else None, bold=True)
            print_colored("👀 The workflow will:", Fore.BLUE if colorama_available else None)
            print("  1. Create an issue with your bug details")
            print("  2. Ask Claude to analyze the bug")
            print("  3. Post Claude's analysis as a comment on the issue")
            print()
            print_colored("Check the GitHub Actions tab for workflow runs:", 
                        Fore.BLUE if colorama_available else None)
            print(f"    https://github.com/{owner}/{repo}/actions")
            print()
            print_colored("And the Issues tab for Claude's analysis (may take a minute):", 
                        Fore.BLUE if colorama_available else None)
            print(f"    https://github.com/{owner}/{repo}/issues")
            return True
        else:
            print_colored(f"❌ Error: GitHub API returned status code {response.status_code}", 
                        Fore.RED if colorama_available else None, bold=True)
            
            try:
                error_data = response.json()
                print(f"Response: {json.dumps(error_data, indent=2)}")
            except:
                print(f"Response: {response.text}")
            
            if response.status_code == 403:
                print()
                print_colored("🔒 This is likely a permissions issue. Your token needs:", 
                            Fore.YELLOW if colorama_available else None)
                print("  1. 'repo' scope for accessing this repository")
                print("  2. 'workflow' scope for triggering workflows")
                print()
                print_colored("Try generating a new token with the correct permissions:", 
                            Fore.BLUE if colorama_available else None)
                print("https://github.com/settings/tokens/new?scopes=repo,workflow")
            
            return False
    except Exception as e:
        print_colored(f"❌ Error: {str(e)}", Fore.RED if colorama_available else None, bold=True)
        return False

def main():
    # Print banner
    print("=" * 50)
    print_colored("🧠 Claude Bug Analyzer", 
                Fore.CYAN if colorama_available else None, bold=True)
    print("=" * 50)
    
    parser = argparse.ArgumentParser(
        description="Trigger Bug Claude Direct workflow for AI bug analysis",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent('''
            Token requirements:
              - Must have 'repo' scope for private repositories
              - Must have 'workflow' scope to trigger workflows
              
            Example:
              python3 trigger_claude_bug.py --token ghp_abc123 --title "Login Crash" --description "App crashes on login screen"
        ''')
    )
    parser.add_argument("--token", "-t", required=True, help="GitHub personal access token")
    parser.add_argument("--title", "-T", required=True, help="Bug title")
    parser.add_argument("--description", "-d", required=True, help="Bug description")
    
    args = parser.parse_args()
    
    # Verify token
    if not check_token(args.token):
        sys.exit(1)
    
    # Trigger workflow
    success = trigger_claude_analysis(args.token, args.title, args.description)
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()