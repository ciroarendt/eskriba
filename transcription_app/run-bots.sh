#!/bin/bash
set -e

# Scriby Bot Automation - Quick Start Script
# This script provides easy access to all bot automation tools

PROJECT_DIR="/Users/ciroarendt/CURSOR/APP_11me/transcription_app"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}🤖 $1${NC}"
    echo -e "${PURPLE}$(printf '=%.0s' {1..50})${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Python is available
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
}

# Check if required directories exist
check_directories() {
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "Project directory not found: $PROJECT_DIR"
        exit 1
    fi
    
    if [ ! -d "$SCRIPTS_DIR" ]; then
        print_error "Scripts directory not found: $SCRIPTS_DIR"
        exit 1
    fi
}

# Main menu
show_menu() {
    clear
    print_header "Scriby Development Bot Orchestrator"
    echo ""
    echo -e "${BLUE}📋 Available Options:${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} 🚀 Run Main Bot Orchestrator (Interactive)"
    echo "  ${GREEN}2.${NC} 🔧 Run Backend Bot (Django + Celery + APIs)"
    echo "  ${GREEN}3.${NC} 📱 Run Mobile Bot (Flutter + Audio + UI)"
    echo "  ${GREEN}4.${NC} 🚢 Run DevOps Bot (Docker + CI/CD + Deploy)"
    echo "  ${GREEN}5.${NC} 📊 Check Dashboard Status"
    echo "  ${GREEN}6.${NC} 🔄 Run All Bots in Parallel"
    echo "  ${GREEN}7.${NC} 📖 View Bot Progress Report"
    echo "  ${GREEN}8.${NC} 🛑 Stop All Running Processes"
    echo "  ${GREEN}9.${NC} ❓ Help & Documentation"
    echo "  ${GREEN}0.${NC} 🚪 Exit"
    echo ""
}

# Run main orchestrator
run_orchestrator() {
    print_header "Starting Main Bot Orchestrator"
    cd "$PROJECT_DIR"
    python3 bot-orchestrator.py
}

# Run individual bots
run_backend_bot() {
    print_header "Starting Backend Bot"
    print_info "This will create Django project, models, APIs, and Celery setup"
    cd "$PROJECT_DIR"
    python3 scripts/backend-bot.py
}

run_mobile_bot() {
    print_header "Starting Mobile Bot"
    print_info "This will implement audio recording, API client, and transcription UI"
    cd "$PROJECT_DIR"
    python3 scripts/mobile-bot.py
}

run_devops_bot() {
    print_header "Starting DevOps Bot"
    print_info "This will setup Docker, CI/CD, monitoring, and deployment scripts"
    cd "$PROJECT_DIR"
    python3 scripts/devops-bot.py
}

# Check dashboard status
check_dashboard() {
    print_header "Checking Dashboard Status"
    
    if curl -f -s http://localhost:3000/api/bot-status > /dev/null 2>&1; then
        print_success "Dashboard is running at http://localhost:3000"
        
        # Try to get status data
        if command -v jq &> /dev/null; then
            echo ""
            print_info "Current Bot Status:"
            curl -s http://localhost:3000/api/bot-status | jq '.bots[] | {name: .name, status: .status, progress: .progress}'
        else
            print_warning "Install 'jq' to see detailed status information"
        fi
    else
        print_error "Dashboard is not running or not accessible"
        print_info "Start the dashboard with: cd scriby-dashboard && npm run dev"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Run all bots in parallel
run_all_bots() {
    print_header "Starting All Bots in Parallel"
    print_warning "This will run all bots simultaneously. Monitor the logs carefully."
    
    echo ""
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "Starting Backend Bot..."
        python3 scripts/backend-bot.py > logs/backend-bot.log 2>&1 &
        BACKEND_PID=$!
        
        print_info "Starting Mobile Bot..."
        python3 scripts/mobile-bot.py > logs/mobile-bot.log 2>&1 &
        MOBILE_PID=$!
        
        print_info "Starting DevOps Bot..."
        python3 scripts/devops-bot.py > logs/devops-bot.log 2>&1 &
        DEVOPS_PID=$!
        
        print_success "All bots started in background"
        print_info "PIDs: Backend=$BACKEND_PID, Mobile=$MOBILE_PID, DevOps=$DEVOPS_PID"
        print_info "Logs are being written to the logs/ directory"
        
        # Save PIDs for later cleanup
        echo "$BACKEND_PID $MOBILE_PID $DEVOPS_PID" > /tmp/scriby-bot-pids
        
        echo ""
        print_info "Monitor progress with option 7 or check logs with:"
        echo "  tail -f logs/backend-bot.log"
        echo "  tail -f logs/mobile-bot.log"
        echo "  tail -f logs/devops-bot.log"
    else
        print_info "Operation cancelled"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# View progress report
view_progress() {
    print_header "Bot Progress Report"
    
    # Check if logs directory exists
    if [ -d "$PROJECT_DIR/logs" ]; then
        echo ""
        print_info "Recent Backend Bot Activity:"
        if [ -f "$PROJECT_DIR/logs/backend-bot.log" ]; then
            tail -n 5 "$PROJECT_DIR/logs/backend-bot.log" | sed 's/^/  /'
        else
            echo "  No backend bot logs found"
        fi
        
        echo ""
        print_info "Recent Mobile Bot Activity:"
        if [ -f "$PROJECT_DIR/logs/mobile-bot.log" ]; then
            tail -n 5 "$PROJECT_DIR/logs/mobile-bot.log" | sed 's/^/  /'
        else
            echo "  No mobile bot logs found"
        fi
        
        echo ""
        print_info "Recent DevOps Bot Activity:"
        if [ -f "$PROJECT_DIR/logs/devops-bot.log" ]; then
            tail -n 5 "$PROJECT_DIR/logs/devops-bot.log" | sed 's/^/  /'
        else
            echo "  No devops bot logs found"
        fi
    else
        print_warning "No logs directory found. Bots may not have been run yet."
    fi
    
    # Check dashboard status
    echo ""
    if curl -f -s http://localhost:3000/api/bot-status > /dev/null 2>&1; then
        print_success "Dashboard is accessible - check http://localhost:3000 for real-time status"
    else
        print_warning "Dashboard is not running - start with: cd scriby-dashboard && npm run dev"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Stop all processes
stop_all() {
    print_header "Stopping All Bot Processes"
    
    # Kill background processes if PID file exists
    if [ -f "/tmp/scriby-bot-pids" ]; then
        PIDS=$(cat /tmp/scriby-bot-pids)
        for pid in $PIDS; do
            if kill -0 $pid 2>/dev/null; then
                print_info "Stopping process $pid"
                kill $pid
            fi
        done
        rm -f /tmp/scriby-bot-pids
        print_success "Background bot processes stopped"
    else
        print_info "No background processes found"
    fi
    
    # Stop any running Python processes related to bots
    pkill -f "bot-orchestrator.py" 2>/dev/null || true
    pkill -f "backend-bot.py" 2>/dev/null || true
    pkill -f "mobile-bot.py" 2>/dev/null || true
    pkill -f "devops-bot.py" 2>/dev/null || true
    
    print_success "All bot processes stopped"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Show help
show_help() {
    print_header "Help & Documentation"
    echo ""
    echo -e "${BLUE}🤖 About Scriby Bot Orchestrator:${NC}"
    echo "  This tool manages 4 specialized development bots for the Scriby project:"
    echo ""
    echo -e "${GREEN}  Backend Bot:${NC} Creates Django project, models, APIs, Celery tasks"
    echo -e "${GREEN}  Mobile Bot:${NC} Implements Flutter audio recording and transcription UI"
    echo -e "${GREEN}  DevOps Bot:${NC} Sets up Docker, CI/CD, monitoring, and deployment"
    echo -e "${GREEN}  Dashboard Bot:${NC} Already completed - manages the admin dashboard"
    echo ""
    echo -e "${BLUE}📁 Project Structure:${NC}"
    echo "  scriby/              - Flutter mobile app"
    echo "  scriby-backend/      - Django backend API"
    echo "  scriby-dashboard/    - Next.js admin dashboard"
    echo "  scriby-infra/        - Docker and deployment configs"
    echo "  scripts/             - Individual bot scripts"
    echo ""
    echo -e "${BLUE}🚀 Quick Start:${NC}"
    echo "  1. Run option 6 to start all bots in parallel"
    echo "  2. Monitor progress with option 7"
    echo "  3. Check dashboard at http://localhost:3000"
    echo ""
    echo -e "${BLUE}📊 Monitoring:${NC}"
    echo "  - Dashboard: http://localhost:3000"
    echo "  - API: http://localhost:8000/api"
    echo "  - Logs: tail -f logs/*.log"
    echo ""
    echo -e "${BLUE}🛠️ Manual Development:${NC}"
    echo "  Each bot can be run individually for step-by-step development"
    echo "  Use the orchestrator (option 1) for interactive control"
    echo ""
    read -p "Press Enter to continue..."
}

# Initialize
init() {
    # Create logs directory
    mkdir -p "$PROJECT_DIR/logs"
    
    # Check requirements
    check_python
    check_directories
}

# Main loop
main() {
    init
    
    while true; do
        show_menu
        read -p "Select an option (0-9): " choice
        
        case $choice in
            1) run_orchestrator ;;
            2) run_backend_bot ;;
            3) run_mobile_bot ;;
            4) run_devops_bot ;;
            5) check_dashboard ;;
            6) run_all_bots ;;
            7) view_progress ;;
            8) stop_all ;;
            9) show_help ;;
            0) 
                print_success "Goodbye! 👋"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 0-9."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main
