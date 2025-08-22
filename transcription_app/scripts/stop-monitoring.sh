#!/bin/bash
echo "🛑 Stopping Scriby Bot Monitoring..."

# Kill monitoring process
pkill -f "bot-monitor.py"

echo "✅ Bot monitoring stopped!"
