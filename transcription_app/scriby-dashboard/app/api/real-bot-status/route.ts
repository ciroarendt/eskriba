import { NextRequest, NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs/promises';
import path from 'path';

const execAsync = promisify(exec);

interface BotMetrics {
  files_created: number;
  files_modified: number;
  commands_executed: number;
  errors_encountered: number;
  session_duration_minutes: number;
}

interface BotStatus {
  id: string;
  name: string;
  status: 'active' | 'idle' | 'inactive' | 'error';
  last_activity: string;
  session_start: string;
  metrics: BotMetrics;
  recent_activities: Array<{
    timestamp: string;
    activity_type: string;
    description: string;
    details?: any;
  }>;
  progress: number;
  isProcessRunning: boolean;
}

interface BotStatusResponse {
  bots: BotStatus[];
  lastUpdated: string;
  totalProgress: number;
}

async function checkBotProcess(botId: string): Promise<boolean> {
  try {
    const { stdout } = await execAsync(`ps aux | grep "${botId}-bot.py --continuous" | grep -v grep`);
    return stdout.trim().length > 0;
  } catch (error) {
    return false;
  }
}

async function readBotLogs(workspacePath: string, botId: string, limit: number = 10) {
  const logFile = path.join(workspacePath, 'logs', `${botId}_activity.jsonl`);
  
  try {
    const content = await fs.readFile(logFile, 'utf-8');
    const lines = content.trim().split('\n').filter(line => line.trim());
    
    // Get last N lines and parse as JSON
    const recentLines = lines.slice(-limit);
    const activities = recentLines.map(line => {
      try {
        return JSON.parse(line);
      } catch {
        return null;
      }
    }).filter(Boolean);
    
    return activities;
  } catch (error) {
    console.log(`No log file found for ${botId}: ${logFile}`);
    return [];
  }
}

async function readRealBotStatus(workspacePath: string) {
  const statusFile = path.join(workspacePath, 'logs', 'bot_status_real.json');
  
  try {
    const content = await fs.readFile(statusFile, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.log(`No real status file found: ${statusFile}`);
    return {};
  }
}

async function getRealBotStatus(botId: string, workspacePath: string): Promise<BotStatus> {
  const isProcessRunning = await checkBotProcess(botId);
  const recentActivities = await readBotLogs(workspacePath, botId, 10);
  const realStatus = await readRealBotStatus(workspacePath);
  
  const botData = realStatus[botId] || {};
  
  // Calculate progress based on real metrics
  const metrics: BotMetrics = botData.metrics || {
    files_created: 0,
    files_modified: 0,
    commands_executed: 0,
    errors_encountered: 0,
    session_duration_minutes: 0
  };
  
  // Progress calculation based on actual work done
  const totalWork = metrics.files_created + metrics.files_modified + metrics.commands_executed;
  const progress = Math.min(100, Math.max(0, totalWork * 2)); // 2% per action
  
  // Determine status based on process and recent activity
  let status: 'active' | 'idle' | 'inactive' | 'error' = 'inactive';
  
  if (metrics.errors_encountered > 5) {
    status = 'error';
  } else if (isProcessRunning) {
    status = 'active';
  } else if (recentActivities.length > 0) {
    const lastActivity = new Date(recentActivities[recentActivities.length - 1]?.timestamp || 0);
    const minutesSinceActivity = (Date.now() - lastActivity.getTime()) / (1000 * 60);
    
    if (minutesSinceActivity < 5) {
      status = 'active';
    } else if (minutesSinceActivity < 15) {
      status = 'idle';
    }
  }
  
  return {
    id: botId,
    name: botId.charAt(0).toUpperCase() + botId.slice(1) + ' Bot',
    status,
    last_activity: botData.last_activity || new Date().toISOString(),
    session_start: botData.session_start || new Date().toISOString(),
    metrics,
    recent_activities: recentActivities.slice(-5), // Last 5 activities
    progress,
    isProcessRunning
  };
}

export async function GET(request: NextRequest) {
  try {
    const workspacePath = '/Users/ciroarendt/CURSOR/APP_11me/transcription_app';
    const botIds = ['backend', 'mobile', 'devops', 'dashboard'];
    
    const botStatuses = await Promise.all(
      botIds.map(botId => getRealBotStatus(botId, workspacePath))
    );
    
    const totalProgress = Math.round(
      botStatuses.reduce((sum, bot) => sum + bot.progress, 0) / botStatuses.length
    );
    
    const response: BotStatusResponse = {
      bots: botStatuses,
      lastUpdated: new Date().toISOString(),
      totalProgress
    };
    
    return NextResponse.json(response);
  } catch (error) {
    console.error('Error getting real bot status:', error);
    return NextResponse.json(
      { error: 'Failed to get bot status', details: error.message },
      { status: 500 }
    );
  }
}
