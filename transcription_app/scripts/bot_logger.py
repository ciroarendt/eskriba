#!/usr/bin/env python3
"""
Real Bot Logger - Structured logging system for bot activities
Tracks real work done by bots with timestamps, metrics, and status
"""

import json
import os
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

class BotLogger:
    def __init__(self, bot_name: str, workspace_path: str):
        self.bot_name = bot_name
        self.workspace_path = Path(workspace_path)
        self.log_dir = self.workspace_path / "logs"
        self.log_dir.mkdir(exist_ok=True)
        
        # Individual bot log file
        self.log_file = self.log_dir / f"{bot_name}_activity.jsonl"
        
        # Shared status file for dashboard
        self.status_file = self.log_dir / "bot_status_real.json"
        
        # Metrics tracking
        self.session_start = datetime.now()
        self.files_created = 0
        self.files_modified = 0
        self.commands_executed = 0
        self.errors_encountered = 0
        
    def log_activity(self, activity_type: str, description: str, details: Dict[str, Any] = None):
        """Log a structured activity entry"""
        timestamp = datetime.now().isoformat()
        
        log_entry = {
            "timestamp": timestamp,
            "bot": self.bot_name,
            "activity_type": activity_type,
            "description": description,
            "details": details or {},
            "session_metrics": {
                "files_created": self.files_created,
                "files_modified": self.files_modified,
                "commands_executed": self.commands_executed,
                "errors_encountered": self.errors_encountered,
                "session_duration_minutes": (datetime.now() - self.session_start).total_seconds() / 60
            }
        }
        
        # Append to individual bot log
        with open(self.log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        # Update shared status
        self._update_shared_status()
        
        print(f"[{self.bot_name.upper()}] {activity_type}: {description}")
        
    def log_file_created(self, file_path: str):
        """Log file creation"""
        self.files_created += 1
        self.log_activity("FILE_CREATED", f"Created {file_path}", {"file_path": file_path})
        
    def log_file_modified(self, file_path: str):
        """Log file modification"""
        self.files_modified += 1
        self.log_activity("FILE_MODIFIED", f"Modified {file_path}", {"file_path": file_path})
        
    def log_command_executed(self, command: str, exit_code: int = 0):
        """Log command execution"""
        self.commands_executed += 1
        self.log_activity("COMMAND_EXECUTED", f"Executed: {command}", {
            "command": command,
            "exit_code": exit_code,
            "success": exit_code == 0
        })
        
    def log_error(self, error_message: str, error_type: str = "GENERAL"):
        """Log error occurrence"""
        self.errors_encountered += 1
        self.log_activity("ERROR", error_message, {
            "error_type": error_type,
            "error_count": self.errors_encountered
        })
        
    def log_cycle_start(self, cycle_number: int):
        """Log start of a development cycle"""
        self.log_activity("CYCLE_START", f"Starting development cycle #{cycle_number}", {
            "cycle_number": cycle_number
        })
        
    def log_cycle_complete(self, cycle_number: int, tasks_completed: List[str]):
        """Log completion of a development cycle"""
        self.log_activity("CYCLE_COMPLETE", f"Completed development cycle #{cycle_number}", {
            "cycle_number": cycle_number,
            "tasks_completed": tasks_completed,
            "task_count": len(tasks_completed)
        })
        
    def _update_shared_status(self):
        """Update shared status file for dashboard consumption"""
        status_data = {}
        
        # Load existing status
        if self.status_file.exists():
            try:
                with open(self.status_file, 'r') as f:
                    status_data = json.load(f)
            except:
                status_data = {}
        
        # Update this bot's status
        status_data[self.bot_name] = {
            "last_activity": datetime.now().isoformat(),
            "status": "active",
            "session_start": self.session_start.isoformat(),
            "metrics": {
                "files_created": self.files_created,
                "files_modified": self.files_modified,
                "commands_executed": self.commands_executed,
                "errors_encountered": self.errors_encountered,
                "session_duration_minutes": round((datetime.now() - self.session_start).total_seconds() / 60, 2)
            }
        }
        
        # Write updated status
        with open(self.status_file, 'w') as f:
            json.dump(status_data, f, indent=2)

class RealBotMonitor:
    """Monitor real bot activities from log files"""
    
    def __init__(self, workspace_path: str):
        self.workspace_path = Path(workspace_path)
        self.log_dir = self.workspace_path / "logs"
        
    def get_recent_activities(self, bot_name: str = None, limit: int = 50) -> List[Dict]:
        """Get recent activities from log files"""
        activities = []
        
        if bot_name:
            log_files = [self.log_dir / f"{bot_name}_activity.jsonl"]
        else:
            log_files = list(self.log_dir.glob("*_activity.jsonl"))
        
        for log_file in log_files:
            if not log_file.exists():
                continue
                
            try:
                with open(log_file, 'r') as f:
                    lines = f.readlines()
                    # Get last N lines
                    for line in lines[-limit:]:
                        activities.append(json.loads(line.strip()))
            except Exception as e:
                print(f"Error reading {log_file}: {e}")
        
        # Sort by timestamp
        activities.sort(key=lambda x: x['timestamp'], reverse=True)
        return activities[:limit]
    
    def get_bot_status_summary(self) -> Dict:
        """Get comprehensive bot status summary"""
        status_file = self.log_dir / "bot_status_real.json"
        
        if not status_file.exists():
            return {"bots": {}, "last_updated": None}
        
        try:
            with open(status_file, 'r') as f:
                data = json.load(f)
            
            # Add activity status based on recent activity
            for bot_name, bot_data in data.items():
                last_activity = datetime.fromisoformat(bot_data['last_activity'])
                minutes_since = (datetime.now() - last_activity).total_seconds() / 60
                
                if minutes_since < 2:
                    bot_data['status'] = 'active'
                elif minutes_since < 10:
                    bot_data['status'] = 'idle'
                else:
                    bot_data['status'] = 'inactive'
            
            return {
                "bots": data,
                "last_updated": datetime.now().isoformat()
            }
        except Exception as e:
            print(f"Error reading status: {e}")
            return {"bots": {}, "last_updated": None}

# Utility functions for easy integration
def create_bot_logger(bot_name: str, workspace_path: str) -> BotLogger:
    """Factory function to create a bot logger"""
    return BotLogger(bot_name, workspace_path)

def get_bot_monitor(workspace_path: str) -> RealBotMonitor:
    """Factory function to create a bot monitor"""
    return RealBotMonitor(workspace_path)
