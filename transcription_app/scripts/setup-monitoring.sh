#!/bin/bash

# Scriby Bot Monitoring Setup Script
# Sets up automatic real-time monitoring for all 4 bots

echo "🚀 Setting up Scriby Bot Monitoring System..."

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is required but not installed."
    exit 1
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3 install watchdog requests

# Make monitoring script executable
chmod +x /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/bot-monitor.py

# Create monitoring service directory
mkdir -p /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring

# Create systemd service file (for Linux) or launchd plist (for macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - Create launchd plist
    cat > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/com.scriby.bot-monitor.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.scriby.bot-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/bot-monitor.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor-error.log</string>
</dict>
</plist>
EOF
    
    echo "✅ Created macOS launchd service file"
    echo "📝 To start monitoring service: launchctl load ~/Library/LaunchAgents/com.scriby.bot-monitor.plist"
    echo "📝 To stop monitoring service: launchctl unload ~/Library/LaunchAgents/com.scriby.bot-monitor.plist"
fi

# Create start/stop scripts
cat > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/start-monitoring.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Scriby Bot Monitoring..."

# Kill any existing monitoring process
pkill -f "bot-monitor.py"

# Start monitoring in background
nohup python3 /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/bot-monitor.py > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor.log 2>&1 &

echo "✅ Bot monitoring started! PID: $!"
echo "📄 Log file: /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor.log"
echo "🌐 Dashboard: http://localhost:3000/monitoring"
EOF

cat > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/stop-monitoring.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping Scriby Bot Monitoring..."

# Kill monitoring process
pkill -f "bot-monitor.py"

echo "✅ Bot monitoring stopped!"
EOF

# Make scripts executable
chmod +x /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/start-monitoring.sh
chmod +x /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/stop-monitoring.sh

# Create dashboard startup script
cat > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/start-dashboard.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting Scriby Monitoring Dashboard..."

cd /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scriby-dashboard

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dashboard dependencies..."
    npm install
fi

# Start dashboard in development mode
echo "🚀 Starting Next.js dashboard on http://localhost:3000"
npm run dev
EOF

chmod +x /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/start-dashboard.sh

echo ""
echo "🎉 Scriby Bot Monitoring System Setup Complete!"
echo ""
echo "📋 Available Commands:"
echo "  🚀 Start monitoring: ./scripts/start-monitoring.sh"
echo "  🛑 Stop monitoring:  ./scripts/stop-monitoring.sh"
echo "  🌐 Start dashboard:  ./scripts/start-dashboard.sh"
echo ""
echo "📊 Monitoring Features:"
echo "  ✅ Real-time file watching across all 4 bot workspaces"
echo "  ✅ Automatic progress calculation and status updates"
echo "  ✅ Live dashboard at http://localhost:3000/monitoring"
echo "  ✅ Auto-updating BOT_STATUS_REALTIME.md file"
echo "  ✅ API endpoint at /api/bot-status for external integrations"
echo ""
echo "🎯 Next Steps:"
echo "  1. Run: ./scripts/start-monitoring.sh"
echo "  2. Run: ./scripts/start-dashboard.sh (in another terminal)"
echo "  3. Open: http://localhost:3000/monitoring"
echo "  4. Start working on any bot - see real-time updates!"
echo ""
