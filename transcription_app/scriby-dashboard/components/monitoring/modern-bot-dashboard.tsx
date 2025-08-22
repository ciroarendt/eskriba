'use client';

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

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

interface MonitoringData {
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

const statusColors = {
  active: 'bg-gradient-to-r from-green-500 to-emerald-500',
  idle: 'bg-gradient-to-r from-yellow-500 to-orange-500',
  error: 'bg-gradient-to-r from-red-500 to-pink-500',
  completed: 'bg-gradient-to-r from-blue-500 to-purple-500'
};

const statusIcons = {
  active: '🚀',
  idle: '⏱️',
  error: '⚠️',
  completed: '✅'
};

const botEmojis = {
  'Backend Bot': '🔧',
  'Dashboard Bot': '📊',
  'Mobile Bot': '📱',
  'DevOps Bot': '⚙️'
};

function StatCard({ title, value, subtitle, icon, gradient }: {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: string;
  gradient: string;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">{value}</p>
          {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
        </div>
        <div className={`w-12 h-12 rounded-lg ${gradient} flex items-center justify-center text-white text-xl`}>
          {icon}
        </div>
      </div>
    </motion.div>
  );
}

function BotCard({ bot, index }: { bot: BotStatus; index: number }) {
  const botEmoji = botEmojis[bot.name as keyof typeof botEmojis] || '🤖';
  
  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.1 }}
      className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all hover:scale-[1.02]"
    >
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="text-2xl">{botEmoji}</div>
          <div>
            <h3 className="font-semibold text-gray-900">{bot.name}</h3>
            <p className="text-sm text-gray-500">{bot.currentTask}</p>
          </div>
        </div>
        <div className={`px-3 py-1 rounded-full text-xs font-medium text-white ${statusColors[bot.status]}`}>
          {statusIcons[bot.status]} {bot.status.toUpperCase()}
        </div>
      </div>
      
      <div className="space-y-3">
        <div>
          <div className="flex justify-between text-sm mb-1">
            <span className="text-gray-600">Progress</span>
            <span className="font-medium">{bot.progress}%</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${bot.progress}%` }}
              transition={{ duration: 0.8, ease: "easeOut" }}
              className="bg-gradient-to-r from-blue-500 to-purple-500 h-2 rounded-full"
            />
          </div>
        </div>
        
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <span className="text-gray-600">Files:</span>
            <span className="font-medium ml-1">{bot.filesCreated}/{bot.totalFiles}</span>
          </div>
          <div>
            <span className="text-gray-600">LOC:</span>
            <span className="font-medium ml-1">{bot.metrics.linesOfCode.toLocaleString()}</span>
          </div>
        </div>
        
        <div className="text-xs text-gray-500">
          Last activity: {bot.lastActivity}
        </div>
      </div>
    </motion.div>
  );
}

export function ModernBotDashboard() {
  const [data, setData] = useState<MonitoringData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [bots, setBots] = useState<BotStatus[]>([]);

  useEffect(() => {
    const fetchBotStatus = async () => {
      try {
        const response = await fetch('/api/real-bot-status');
        const data = await response.json();
        setBots(data.bots || []);
      } catch (error) {
        console.error('Failed to fetch real bot status:', error);
        // Fallback to old API if real API fails
        try {
          const fallbackResponse = await fetch('/api/bot-status');
          const fallbackData = await fallbackResponse.json();
          setBots(fallbackData.bots || []);
        } catch (fallbackError) {
          console.error('Both APIs failed:', fallbackError);
        }
      }
    };

    const fetchData = async () => {
      try {
        setError(null);
        const response = await fetch('/api/bot-status');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const result = await response.json();
        setData(result);
      } catch (error) {
        setError(error instanceof Error ? error.message : 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 border-4 border-blue-500/30 border-t-blue-500 rounded-full animate-spin"></div>
          <span className="text-gray-600">Loading dashboard...</span>
        </div>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="text-center py-12">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 max-w-md mx-auto">
          <div className="text-red-500 text-4xl mb-4">⚠️</div>
          <h3 className="text-lg font-semibold text-red-800 mb-2">Connection Error</h3>
          <p className="text-red-600">{error || 'Unable to load dashboard data'}</p>
        </div>
      </div>
    );
  }

  const totalFiles = data.bots.reduce((sum, bot) => sum + bot.totalFiles, 0);
  const totalLOC = data.bots.reduce((sum, bot) => sum + bot.metrics.linesOfCode, 0);
  const avgProgress = Math.round(data.bots.reduce((sum, bot) => sum + bot.progress, 0) / data.bots.length);
  const activeBots = data.bots.filter(bot => bot.status === 'active').length;

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent mb-2">
          Scriby Development Hub
        </h1>
        <p className="text-gray-600">Real-time monitoring of parallel bot development</p>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Active Bots"
          value={activeBots}
          subtitle={`of ${data.bots.length} total`}
          icon="🤖"
          gradient="bg-gradient-to-r from-blue-500 to-purple-500"
        />
        <StatCard
          title="Overall Progress"
          value={`${avgProgress}%`}
          subtitle="Average completion"
          icon="📈"
          gradient="bg-gradient-to-r from-green-500 to-emerald-500"
        />
        <StatCard
          title="Total Files"
          value={totalFiles.toLocaleString()}
          subtitle="Across all projects"
          icon="📁"
          gradient="bg-gradient-to-r from-orange-500 to-red-500"
        />
        <StatCard
          title="Lines of Code"
          value={totalLOC.toLocaleString()}
          subtitle="Generated so far"
          icon="💻"
          gradient="bg-gradient-to-r from-purple-500 to-pink-500"
        />
      </div>

      {/* Bot Cards */}
      <div>
        <h2 className="text-xl font-semibold text-gray-900 mb-6">Bot Status</h2>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {data.bots.map((bot, index) => (
            <BotCard key={bot.id} bot={bot} index={index} />
          ))}
        </div>
      </div>

      {/* System Coordination */}
      <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">System Coordination</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600">{data.coordination.integrationPoints}</div>
            <div className="text-sm text-gray-600">Integration Points</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-600">{data.coordination.conflicts}</div>
            <div className="text-sm text-gray-600">Conflicts</div>
          </div>
          <div className="text-center">
            <div className={`text-2xl font-bold ${
              data.coordination.syncStatus === 'synced' ? 'text-green-600' :
              data.coordination.syncStatus === 'pending' ? 'text-yellow-600' : 'text-red-600'
            }`}>
              {data.coordination.syncStatus === 'synced' ? '✅' :
               data.coordination.syncStatus === 'pending' ? '⏳' : '❌'}
            </div>
            <div className="text-sm text-gray-600 capitalize">{data.coordination.syncStatus}</div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="text-center text-sm text-gray-500">
        Last updated: {new Date(data.timestamp).toLocaleString()}
      </div>
    </div>
  );
}
