import { NextRequest, NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import * as path from 'path';

const execAsync = promisify(exec);

interface BotStatus {
  id: string;
  name: string;
  status: 'active' | 'idle' | 'error' | 'completed';
  progress: number;
  filesCreated: number;
  totalFiles: number;
  lastActivity: string;
  currentTask: string;
  errors: string[];
  metrics: {
    linesOfCode: number;
    commits: number;
    testsWritten: number;
    apiEndpoints: number;
  };
}

interface BotMonitoringData {
  timestamp: string;
  bots: BotStatus[];
  coordination: {
    integrationPoints: number;
    conflicts: number;
    syncStatus: 'synced' | 'pending' | 'conflict';
  };
  efficiency: {
    parallelSpeedup: number;
    timelineProgress: number;
    estimatedCompletion: string;
  };
}

// Bot workspace paths
const BOT_WORKSPACES = {
  backend: '/Users/ciroarendt/CURSOR/APP_11me/transcription_app/scriby-backend',
  dashboard: '/Users/ciroarendt/CURSOR/APP_11me/transcription_app/scriby-dashboard',
  mobile: '/Users/ciroarendt/CURSOR/APP_11me/transcription_app/scriby',
  devops: '/Users/ciroarendt/CURSOR/APP_11me/transcription_app/scriby-infra',
};

// Expected files for each bot (for progress calculation)
const EXPECTED_FILES = {
  backend: [
    'requirements.txt', 'manage.py', 'config/settings/base.py', 'config/settings/development.py',
    'config/settings/production.py', 'config/urls.py', 'config/wsgi.py', 'config/celery.py',
    'apps/users/models.py', 'apps/users/serializers.py', 'apps/users/views.py',
    'apps/transcriptions/models.py', 'apps/transcriptions/serializers.py', 'apps/transcriptions/views.py',
    'apps/analytics/models.py', 'apps/analytics/views.py', 'apps/billing/models.py'
  ],
  dashboard: [
    'package.json', 'next.config.js', 'app/layout.tsx', 'app/page.tsx', 'app/globals.css',
    'components/layout/sidebar.tsx', 'components/layout/header.tsx', 'components/ui/button.tsx',
    'components/charts/aarrr-metrics.tsx', 'components/charts/cost-monitoring.tsx',
    'app/dashboard/page.tsx', 'app/auth/login/page.tsx'
  ],
  mobile: [
    'lib/core/api/api_client.dart', 'lib/features/transcription/providers/transcription_provider.dart',
    'lib/features/transcription/models/transcription_model.dart', 'lib/features/auth/providers/auth_provider.dart',
    'lib/shared/widgets/upload_button.dart', 'lib/features/sync/providers/sync_provider.dart',
    'lib/core/storage/local_storage.dart', 'lib/features/recording/widgets/recording_controls.dart'
  ],
  devops: [
    'docker-compose.yml', '.env.example', 'Dockerfile.backend', 'Dockerfile.dashboard',
    'docker/database/init.sql', '.github/workflows/ci.yml', '.github/workflows/deploy.yml',
    'scripts/deploy.sh', 'monitoring/prometheus.yml', 'monitoring/grafana-dashboard.json'
  ]
};

// Get file statistics for a workspace
async function getFileStats(workspacePath: string, extensions: string[]) {
  try {
    console.log(`[DEBUG] Getting file stats for: ${workspacePath}`);
    
    if (!fs.existsSync(workspacePath)) {
      console.log(`[DEBUG] Workspace does not exist: ${workspacePath}`);
      return { fileCount: 0, linesOfCode: 0 };
    }

    // Use a simpler approach - just count files recursively
    let fileCount = 0;
    let linesOfCode = 0;

    try {
      // Simple file counting using Node.js APIs instead of shell commands
      const countFiles = (dir: string): number => {
        let count = 0;
        try {
          const items = fs.readdirSync(dir);
          for (const item of items) {
            const fullPath = path.join(dir, item);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
              count += countFiles(fullPath);
            } else if (stat.isFile()) {
              const ext = path.extname(item).slice(1);
              if (extensions.includes(ext)) {
                count++;
                // Count lines in file
                try {
                  const content = fs.readFileSync(fullPath, 'utf8');
                  linesOfCode += content.split('\n').length;
                } catch (e) {
                  // Skip files we can't read
                }
              }
            }
          }
        } catch (e) {
          // Skip directories we can't read
        }
        return count;
      };

      fileCount = countFiles(workspacePath);
    } catch (error) {
      console.error(`[ERROR] Failed to count files in ${workspacePath}:`, error);
    }

    console.log(`[DEBUG] File count result: ${fileCount}, Lines: ${linesOfCode}`);
    return { fileCount, linesOfCode };
  } catch (error) {
    console.error(`[ERROR] Failed to get file stats for ${workspacePath}:`, error);
    return { fileCount: 0, linesOfCode: 0 };
  }
}

async function getLinesOfCode(workspacePath: string): Promise<number> {
  try {
    const extensions = ['py', 'ts', 'tsx', 'dart'];
    const { linesOfCode } = await getFileStats(workspacePath, extensions);
    return linesOfCode;
  } catch (error) {
    console.error(`Error getting lines of code for ${workspacePath}:`, error);
    return 0;
  }
}

async function getGitCommits(workspacePath: string): Promise<number> {
  try {
    const { stdout } = await execAsync(`cd "${workspacePath}" && git rev-list --count HEAD 2>/dev/null || echo "0"`);
    return parseInt(stdout.trim()) || 0;
  } catch (error) {
    return 0;
  }
}

async function checkBotProcess(botId: string): Promise<boolean> {
  try {
    // Check if bot process is running with --continuous flag
    const { stdout } = await execAsync(`ps aux | grep "${botId}-bot.py --continuous" | grep -v grep`);
    return stdout.trim().length > 0;
  } catch (error) {
    // If grep finds no matches, it returns exit code 1, which throws an error
    // This is expected when no processes are found
    return false;
  }
}

async function getBotStatus(botId: string, workspacePath: string): Promise<BotStatus> {
  console.log(`[DEBUG] getBotStatus called for bot: ${botId}, workspace: ${workspacePath}`);
  const expectedFiles = EXPECTED_FILES[botId as keyof typeof EXPECTED_FILES] || [];
  const extensions = ['py', 'ts', 'tsx', 'dart', 'yml', 'yaml', 'json'];
  const { fileCount: filesCreated, linesOfCode } = await getFileStats(workspacePath, extensions);
  console.log(`[DEBUG] filesCreated for ${botId}: ${filesCreated}`);
  console.log(`[DEBUG] linesOfCode for ${botId}: ${linesOfCode}`);
  const commits = await getGitCommits(workspacePath);
  console.log(`[DEBUG] commits for ${botId}: ${commits}`);
  
  // Get last modified time
  let lastModified: Date | null = null;
  try {
    if (fs.existsSync(workspacePath)) {
      const stat = fs.statSync(workspacePath);
      lastModified = stat.mtime;
    }
  } catch (error) {
    console.error(`Error getting last modified time for ${workspacePath}:`, error);
  }

  // Calculate progress based on expected files
  const existingFiles = expectedFiles.filter(file => 
    fs.existsSync(path.join(workspacePath, file))
  );
  const progress = expectedFiles.length > 0 ? (existingFiles.length / expectedFiles.length) * 100 : 0;

  // Check if bot process is running
  const isProcessRunning = await checkBotProcess(botId);
  
  // Determine status based on running process and activity
  const now = new Date();
  const minutesSinceActivity = lastModified ? (now.getTime() - lastModified.getTime()) / (1000 * 60) : Infinity;
  
  let status: BotStatus['status'] = 'idle';
  if (isProcessRunning) {
    status = 'active';
    // Update lastModified to now if process is running
    lastModified = new Date();
  } else if (minutesSinceActivity < 5) {
    status = 'active';
  } else if (progress >= 100) {
    status = 'completed';
  } else {
    status = 'idle';
  }

  // Determine current task based on progress
  let currentTask = 'Initializing...';
  if (progress < 25) currentTask = 'Setting up project structure';
  else if (progress < 50) currentTask = 'Implementing core features';
  else if (progress < 75) currentTask = 'Integration and testing';
  else if (progress < 100) currentTask = 'Finalizing and optimization';
  else currentTask = 'Completed';

  return {
    id: botId,
    name: `${botId.charAt(0).toUpperCase() + botId.slice(1)} Bot`,
    status,
    progress: Math.round(progress),
    filesCreated,
    totalFiles: expectedFiles.length,
    lastActivity: lastModified ? lastModified.toISOString() : 'Never',
    currentTask,
    errors: [], // TODO: Implement error detection
    metrics: {
      linesOfCode,
      commits,
      testsWritten: 0, // TODO: Count test files
      apiEndpoints: 0, // TODO: Count API endpoints
    }
  };
}

export async function GET(request: NextRequest) {
  try {
    const bots: BotStatus[] = [];
    
    // Get status for each bot
    for (const [botId, workspacePath] of Object.entries(BOT_WORKSPACES)) {
      const botStatus = await getBotStatus(botId, workspacePath);
      bots.push(botStatus);
    }

    // Calculate coordination metrics
    const activeBots = bots.filter(bot => bot.status === 'active').length;
    const completedBots = bots.filter(bot => bot.status === 'completed').length;
    const avgProgress = bots.reduce((sum, bot) => sum + bot.progress, 0) / bots.length;

    // Calculate efficiency metrics
    const totalFiles = bots.reduce((sum, bot) => sum + bot.filesCreated, 0);
    const parallelSpeedup = activeBots > 1 ? activeBots * 0.8 : 1; // 80% efficiency for parallel work
    const timelineProgress = avgProgress;

    // Estimate completion (6 weeks = 42 days)
    const daysRemaining = Math.max(0, 42 * (1 - timelineProgress / 100));
    const estimatedCompletion = new Date(Date.now() + daysRemaining * 24 * 60 * 60 * 1000).toISOString();

    const monitoringData: BotMonitoringData = {
      timestamp: new Date().toISOString(),
      bots,
      coordination: {
        integrationPoints: 4, // Backend, Dashboard, Mobile, DevOps
        conflicts: 0, // TODO: Implement conflict detection
        syncStatus: avgProgress > 0 ? 'synced' : 'pending',
      },
      efficiency: {
        parallelSpeedup,
        timelineProgress,
        estimatedCompletion,
      }
    };

    return NextResponse.json(monitoringData);
  } catch (error) {
    console.error('Error getting bot status:', error);
    return NextResponse.json(
      { error: 'Failed to get bot status' },
      { status: 500 }
    );
  }
}
