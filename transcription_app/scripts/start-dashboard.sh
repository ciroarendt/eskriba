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
