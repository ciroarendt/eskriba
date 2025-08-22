#!/bin/bash
echo "🚀 Starting Scriby Bot Monitoring..."

# Kill any existing monitoring process
pkill -f "bot-monitor.py"

# Start monitoring in background
nohup python3 /Users/ciroarendt/CURSOR/APP_11me/transcription_app/scripts/bot-monitor.py > /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor.log 2>&1 &

echo "✅ Bot monitoring started! PID: $!"
echo "📄 Log file: /Users/ciroarendt/CURSOR/APP_11me/transcription_app/monitoring/bot-monitor.log"
echo "🌐 Dashboard: http://localhost:3000/monitoring"
