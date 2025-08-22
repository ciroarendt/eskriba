#!/usr/bin/env python3
"""
Bot Activity Demo - Visual demonstration of bot activity
Creates visible changes to show bots are working
"""

import os
import time
import random
from datetime import datetime
from pathlib import Path

class BotActivityDemo:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.demo_files = {
            'backend': self.project_path / 'scriby-backend' / 'demo_activity.log',
            'mobile': self.project_path / 'scriby' / 'demo_activity.log',
            'devops': self.project_path / 'scriby-infra' / 'demo_activity.log',
            'dashboard': self.project_path / 'scriby-dashboard' / 'demo_activity.log'
        }
        
    def create_visible_activity(self):
        """Create visible file changes to demonstrate bot activity"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        activities = [
            "🔧 Configuring Django models and views",
            "📱 Implementing Flutter audio recording",
            "🚢 Setting up Docker containers", 
            "📊 Creating dashboard components",
            "🔄 Running database migrations",
            "🎨 Styling UI components",
            "🔐 Configuring authentication",
            "📡 Setting up API endpoints",
            "🧪 Writing unit tests",
            "📝 Updating documentation"
        ]
        
        for bot_name, file_path in self.demo_files.items():
            # Ensure directory exists
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Add activity log entry
            activity = random.choice(activities)
            log_entry = f"[{timestamp}] {bot_name.upper()} BOT: {activity}\n"
            
            with open(file_path, 'a') as f:
                f.write(log_entry)
            
            print(f"✅ {bot_name.title()} Bot: {activity}")
        
        # Create progress files with increasing numbers
        progress_file = self.project_path / 'bot_progress.txt'
        current_progress = 0
        
        if progress_file.exists():
            try:
                with open(progress_file, 'r') as f:
                    current_progress = int(f.read().strip())
            except:
                current_progress = 0
        
        current_progress += random.randint(1, 5)
        
        with open(progress_file, 'w') as f:
            f.write(str(current_progress))
        
        print(f"📈 Total Progress: {current_progress} operations completed")
        
    def run_demo_cycle(self):
        """Run one cycle of demo activity"""
        print(f"\n🔄 Bot Activity Demo - {datetime.now().strftime('%H:%M:%S')}")
        print("=" * 60)
        
        self.create_visible_activity()
        
        # Create some temporary files to show file creation activity
        temp_files = [
            'temp_model.py',
            'temp_widget.dart', 
            'temp_config.yml',
            'temp_component.tsx'
        ]
        
        for i, (bot_name, _) in enumerate(self.demo_files.items()):
            if i < len(temp_files):
                temp_file = self.project_path / f"temp_{bot_name}_{temp_files[i]}"
                with open(temp_file, 'w') as f:
                    f.write(f"// Demo file created by {bot_name} bot at {datetime.now()}\n")
                print(f"📄 Created: {temp_file.name}")
        
        print("=" * 60)
        print("✅ Demo cycle completed - Check dashboard for updates!")

def main():
    demo = BotActivityDemo("/Users/ciroarendt/CURSOR/APP_11me/transcription_app")
    
    print("🎬 Starting Bot Activity Demo")
    print("This will create visible changes to show bot activity")
    print("Watch the dashboard at http://localhost:3000 for updates!")
    print("\nPress Ctrl+C to stop the demo\n")
    
    try:
        while True:
            demo.run_demo_cycle()
            time.sleep(10)  # Wait 10 seconds between cycles
    except KeyboardInterrupt:
        print("\n🛑 Demo stopped")

if __name__ == "__main__":
    main()
