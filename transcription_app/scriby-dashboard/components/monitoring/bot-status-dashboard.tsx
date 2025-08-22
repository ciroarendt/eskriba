'use client';

import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { Progress } from '../ui/progress';
import { Badge } from '../ui/badge';
import { Separator } from '../ui/separator';
import { 
  Activity, 
  CheckCircle, 
  Clock, 
  AlertCircle, 
  Code, 
  GitCommit, 
  FileText, 
  Zap,
  TrendingUp,
  Users
} from 'lucide-react';

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

const getStatusIcon = (status: BotStatus['status']) => {
  switch (status) {
    case 'active':
      return <Activity className="h-4 w-4 text-green-500 animate-pulse" />;
    case 'completed':
      return <CheckCircle className="h-4 w-4 text-blue-500" />;
    case 'error':
      return <AlertCircle className="h-4 w-4 text-red-500" />;
    default:
      return <Clock className="h-4 w-4 text-gray-400" />;
  }
};

const getStatusColor = (status: BotStatus['status']) => {
  switch (status) {
    case 'active':
      return 'bg-green-500';
    case 'completed':
      return 'bg-blue-500';
    case 'error':
      return 'bg-red-500';
    default:
      return 'bg-gray-400';
  }
};

const getStatusBadge = (status: BotStatus['status']) => {
  const variants = {
    active: 'default',
    completed: 'secondary',
    error: 'destructive',
    idle: 'outline'
  } as const;

  return (
    <Badge variant={variants[status]} className="capitalize">
      {status}
    </Badge>
  );
};

const BotCard: React.FC<{ bot: BotStatus }> = ({ bot }) => {
  const timeSinceActivity = bot.lastActivity !== 'Never' 
    ? Math.round((Date.now() - new Date(bot.lastActivity).getTime()) / (1000 * 60))
    : null;

  return (
    <Card className="relative overflow-hidden">
      {/* Status indicator bar */}
      <div className={`absolute top-0 left-0 right-0 h-1 ${getStatusColor(bot.status)}`} />
      
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg font-semibold flex items-center gap-2">
            {getStatusIcon(bot.status)}
            {bot.name}
          </CardTitle>
          {getStatusBadge(bot.status)}
        </div>
        <CardDescription className="text-sm">
          {bot.currentTask}
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        {/* Progress */}
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Progress</span>
            <span className="font-medium">{bot.progress}%</span>
          </div>
          <Progress value={bot.progress} className="h-2" />
        </div>

        {/* Files */}
        <div className="flex justify-between items-center text-sm">
          <span className="flex items-center gap-1">
            <FileText className="h-3 w-3" />
            Files
          </span>
          <span className="font-medium">
            {bot.filesCreated}/{bot.totalFiles}
          </span>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-2 gap-2 text-xs">
          <div className="flex items-center gap-1">
            <Code className="h-3 w-3 text-blue-500" />
            <span>{bot.metrics.linesOfCode.toLocaleString()} LOC</span>
          </div>
          <div className="flex items-center gap-1">
            <GitCommit className="h-3 w-3 text-green-500" />
            <span>{bot.metrics.commits} commits</span>
          </div>
        </div>

        {/* Last Activity */}
        <div className="text-xs text-muted-foreground">
          Last activity: {
            timeSinceActivity !== null 
              ? timeSinceActivity < 1 
                ? 'Just now'
                : timeSinceActivity < 60
                  ? `${timeSinceActivity}m ago`
                  : `${Math.round(timeSinceActivity / 60)}h ago`
              : 'Never'
          }
        </div>

        {/* Errors */}
        {bot.errors.length > 0 && (
          <div className="text-xs text-red-600 bg-red-50 p-2 rounded">
            {bot.errors.length} error(s) detected
          </div>
        )}
      </CardContent>
    </Card>
  );
};

const CoordinationPanel: React.FC<{ data: BotMonitoringData }> = ({ data }) => {
  const { coordination, efficiency } = data;
  const activeBots = data.bots.filter(bot => bot.status === 'active').length;
  const completedBots = data.bots.filter(bot => bot.status === 'completed').length;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Users className="h-5 w-5" />
          Coordination & Efficiency
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Active Bots */}
        <div className="flex justify-between items-center">
          <span className="text-sm">Active Bots</span>
          <Badge variant={activeBots > 0 ? 'default' : 'secondary'}>
            {activeBots}/4
          </Badge>
        </div>

        {/* Timeline Progress */}
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>Timeline Progress</span>
            <span className="font-medium">{efficiency.timelineProgress.toFixed(1)}%</span>
          </div>
          <Progress value={efficiency.timelineProgress} className="h-2" />
        </div>

        <Separator />

        {/* Efficiency Metrics */}
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div className="space-y-1">
            <div className="flex items-center gap-1">
              <Zap className="h-3 w-3 text-yellow-500" />
              <span>Parallel Speedup</span>
            </div>
            <div className="font-medium">{efficiency.parallelSpeedup.toFixed(1)}x</div>
          </div>
          
          <div className="space-y-1">
            <div className="flex items-center gap-1">
              <TrendingUp className="h-3 w-3 text-green-500" />
              <span>Integration Points</span>
            </div>
            <div className="font-medium">{coordination.integrationPoints}/4</div>
          </div>
        </div>

        {/* Sync Status */}
        <div className="flex justify-between items-center">
          <span className="text-sm">Sync Status</span>
          <Badge variant={coordination.syncStatus === 'synced' ? 'default' : 'outline'}>
            {coordination.syncStatus}
          </Badge>
        </div>

        {/* Estimated Completion */}
        <div className="text-xs text-muted-foreground">
          Estimated completion: {new Date(efficiency.estimatedCompletion).toLocaleDateString()}
        </div>

        {/* Conflicts */}
        {coordination.conflicts > 0 && (
          <div className="text-xs text-red-600 bg-red-50 p-2 rounded">
            ⚠️ {coordination.conflicts} integration conflict(s) detected
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export const BotStatusDashboard: React.FC = () => {
  const [data, setData] = useState<BotMonitoringData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdate, setLastUpdate] = useState<Date | null>(null);

  const fetchBotStatus = async () => {
    try {
      const response = await fetch('/api/bot-status');
      if (!response.ok) {
        throw new Error('Failed to fetch bot status');
      }
      const newData = await response.json();
      setData(newData);
      setLastUpdate(new Date());
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchBotStatus();

    // Set up polling every 30 seconds
    const interval = setInterval(fetchBotStatus, 30000);

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="p-6">
          <div className="text-center text-red-600">
            <AlertCircle className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading bot status: {error}</p>
            <button 
              onClick={fetchBotStatus}
              className="mt-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              Retry
            </button>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!data) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Bot Status Dashboard</h1>
          <p className="text-muted-foreground">
            Real-time monitoring of 4 parallel development bots
          </p>
        </div>
        <div className="text-right text-sm text-muted-foreground">
          <div>Last updated: {lastUpdate?.toLocaleTimeString()}</div>
          <div className="flex items-center gap-1 mt-1">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <span>Live</span>
          </div>
        </div>
      </div>

      {/* Coordination Panel */}
      <CoordinationPanel data={data} />

      {/* Bot Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {data.bots.map((bot) => (
          <BotCard key={bot.id} bot={bot} />
        ))}
      </div>

      {/* Summary Stats */}
      <Card>
        <CardHeader>
          <CardTitle>Development Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
            <div>
              <div className="text-2xl font-bold text-blue-600">
                {data.bots.reduce((sum, bot) => sum + bot.filesCreated, 0)}
              </div>
              <div className="text-sm text-muted-foreground">Total Files</div>
            </div>
            <div>
              <div className="text-2xl font-bold text-green-600">
                {data.bots.reduce((sum, bot) => sum + bot.metrics.linesOfCode, 0).toLocaleString()}
              </div>
              <div className="text-sm text-muted-foreground">Lines of Code</div>
            </div>
            <div>
              <div className="text-2xl font-bold text-purple-600">
                {data.bots.reduce((sum, bot) => sum + bot.metrics.commits, 0)}
              </div>
              <div className="text-sm text-muted-foreground">Total Commits</div>
            </div>
            <div>
              <div className="text-2xl font-bold text-orange-600">
                {data.efficiency.parallelSpeedup.toFixed(1)}x
              </div>
              <div className="text-sm text-muted-foreground">Speedup</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
