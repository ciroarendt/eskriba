'use client'

import React, { useState, useEffect } from 'react'
// Simple UI components to avoid dependency issues
const Card = ({ children, className = '' }: { children: React.ReactNode, className?: string }) => (
  <div className={`rounded-lg border shadow-sm ${className}`}>{children}</div>
)
const CardHeader = ({ children }: { children: React.ReactNode }) => (
  <div className="p-6 pb-4">{children}</div>
)
const CardTitle = ({ children, className = '' }: { children: React.ReactNode, className?: string }) => (
  <h3 className={`text-lg font-semibold ${className}`}>{children}</h3>
)
const CardContent = ({ children, className = '' }: { children: React.ReactNode, className?: string }) => (
  <div className={`p-6 pt-0 ${className}`}>{children}</div>
)
const Badge = ({ children, className = '', variant = 'default' }: { children: React.ReactNode, className?: string, variant?: string }) => (
  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${className}`}>{children}</span>
)
const Progress = ({ value, className = '' }: { value: number, className?: string }) => (
  <div className={`w-full bg-gray-200 rounded-full ${className}`}>
    <div className="bg-blue-600 h-full rounded-full transition-all duration-300" style={{ width: `${value}%` }}></div>
  </div>
)
import { CheckCircle, Clock, AlertCircle, Play, Pause } from 'lucide-react'

interface BotTask {
  id: string
  name: string
  status: 'completed' | 'in_progress' | 'pending' | 'blocked'
  progress: number
  estimatedTime: string
  actualTime?: string
  dependencies: string[]
  files: string[]
  description: string
}

interface BotRoadmap {
  id: string
  name: string
  icon: string
  status: 'active' | 'idle' | 'completed' | 'error'
  overallProgress: number
  currentTask: string
  tasks: BotTask[]
  metrics: {
    filesCreated: number
    linesOfCode: number
    testsWritten: number
    endpointsCreated: number
    modelsCreated: number
  }
}

const ROADMAPS: BotRoadmap[] = [
  {
    id: 'backend',
    name: 'Backend Django Bot',
    icon: '🔧',
    status: 'active',
    overallProgress: 60,
    currentTask: 'Creating API Views',
    tasks: [
      {
        id: 'models',
        name: 'Django Models',
        status: 'completed',
        progress: 100,
        estimatedTime: '30min',
        actualTime: '25min',
        dependencies: [],
        files: ['models.py'],
        description: 'User, Recording, Transcription, Analysis models with relationships'
      },
      {
        id: 'serializers',
        name: 'DRF Serializers',
        status: 'completed',
        progress: 100,
        estimatedTime: '45min',
        actualTime: '35min',
        dependencies: ['models'],
        files: ['serializers.py'],
        description: 'API serializers with validation and nested relationships'
      },
      {
        id: 'views',
        name: 'API ViewSets',
        status: 'in_progress',
        progress: 80,
        estimatedTime: '60min',
        dependencies: ['serializers'],
        files: ['views.py'],
        description: 'REST API endpoints with authentication and permissions'
      },
      {
        id: 'tasks',
        name: 'Celery Tasks',
        status: 'pending',
        progress: 0,
        estimatedTime: '40min',
        dependencies: ['views'],
        files: ['tasks.py'],
        description: 'Async audio processing and AI analysis tasks'
      },
      {
        id: 'tests',
        name: 'Unit Tests',
        status: 'pending',
        progress: 0,
        estimatedTime: '50min',
        dependencies: ['tasks'],
        files: ['tests.py'],
        description: 'Comprehensive test coverage for all components'
      },
      {
        id: 'urls',
        name: 'URL Configuration',
        status: 'pending',
        progress: 0,
        estimatedTime: '15min',
        dependencies: ['views'],
        files: ['urls.py'],
        description: 'API routing and endpoint configuration'
      }
    ],
    metrics: {
      filesCreated: 3,
      linesOfCode: 2156,
      testsWritten: 0,
      endpointsCreated: 15,
      modelsCreated: 8
    }
  },
  {
    id: 'dashboard',
    name: 'Dashboard Next.js Bot',
    icon: '📊',
    status: 'active',
    overallProgress: 45,
    currentTask: 'Enhanced Monitoring UI',
    tasks: [
      {
        id: 'setup',
        name: 'Project Setup',
        status: 'completed',
        progress: 100,
        estimatedTime: '20min',
        actualTime: '15min',
        dependencies: [],
        files: ['package.json', 'next.config.js'],
        description: 'Next.js 14 setup with Tailwind and TypeScript'
      },
      {
        id: 'basic-ui',
        name: 'Basic Dashboard UI',
        status: 'completed',
        progress: 100,
        estimatedTime: '40min',
        actualTime: '45min',
        dependencies: ['setup'],
        files: ['page.tsx', 'layout.tsx'],
        description: 'Basic monitoring interface with real-time updates'
      },
      {
        id: 'enhanced-ui',
        name: 'Enhanced Monitoring',
        status: 'in_progress',
        progress: 70,
        estimatedTime: '60min',
        dependencies: ['basic-ui'],
        files: ['EnhancedBotDashboard.tsx'],
        description: 'Detailed roadmap visualization and granular progress tracking'
      },
      {
        id: 'api-integration',
        name: 'Backend API Integration',
        status: 'pending',
        progress: 0,
        estimatedTime: '30min',
        dependencies: ['enhanced-ui'],
        files: ['api-client.ts'],
        description: 'Integration with Django backend APIs'
      },
      {
        id: 'real-time',
        name: 'Real-time Updates',
        status: 'pending',
        progress: 0,
        estimatedTime: '45min',
        dependencies: ['api-integration'],
        files: ['websocket.ts'],
        description: 'WebSocket integration for live progress updates'
      }
    ],
    metrics: {
      filesCreated: 12,
      linesOfCode: 1850,
      testsWritten: 0,
      endpointsCreated: 3,
      modelsCreated: 0
    }
  },
  {
    id: 'mobile',
    name: 'Mobile Flutter Bot',
    icon: '📱',
    status: 'active',
    overallProgress: 35,
    currentTask: 'Audio Recording Integration',
    tasks: [
      {
        id: 'setup',
        name: 'Flutter Setup',
        status: 'completed',
        progress: 100,
        estimatedTime: '25min',
        actualTime: '30min',
        dependencies: [],
        files: ['pubspec.yaml'],
        description: 'Flutter dependencies and project configuration'
      },
      {
        id: 'ui-components',
        name: 'UI Components',
        status: 'completed',
        progress: 100,
        estimatedTime: '50min',
        actualTime: '55min',
        dependencies: ['setup'],
        files: ['main.dart', 'home_page.dart'],
        description: 'Recording button, UI widgets, and navigation'
      },
      {
        id: 'audio-recording',
        name: 'Audio Recording',
        status: 'in_progress',
        progress: 60,
        estimatedTime: '70min',
        dependencies: ['ui-components'],
        files: ['audio_service.dart'],
        description: 'flutter_sound integration with permissions'
      },
      {
        id: 'api-client',
        name: 'API Client',
        status: 'pending',
        progress: 0,
        estimatedTime: '40min',
        dependencies: ['audio-recording'],
        files: ['api_client.dart'],
        description: 'HTTP client for backend communication'
      },
      {
        id: 'state-management',
        name: 'State Management',
        status: 'pending',
        progress: 0,
        estimatedTime: '45min',
        dependencies: ['api-client'],
        files: ['providers.dart'],
        description: 'Provider pattern for app state management'
      }
    ],
    metrics: {
      filesCreated: 8,
      linesOfCode: 1200,
      testsWritten: 0,
      endpointsCreated: 0,
      modelsCreated: 3
    }
  },
  {
    id: 'devops',
    name: 'DevOps Infrastructure Bot',
    icon: '🚀',
    status: 'active',
    overallProgress: 25,
    currentTask: 'Docker Configuration',
    tasks: [
      {
        id: 'docker-setup',
        name: 'Docker Configuration',
        status: 'in_progress',
        progress: 80,
        estimatedTime: '45min',
        dependencies: [],
        files: ['docker-compose.yml', 'Dockerfile'],
        description: 'Multi-service Docker setup with PostgreSQL, Redis, Celery'
      },
      {
        id: 'ci-cd',
        name: 'CI/CD Pipeline',
        status: 'pending',
        progress: 0,
        estimatedTime: '60min',
        dependencies: ['docker-setup'],
        files: ['.github/workflows/deploy.yml'],
        description: 'GitHub Actions for automated testing and deployment'
      },
      {
        id: 'monitoring',
        name: 'Monitoring Setup',
        status: 'pending',
        progress: 0,
        estimatedTime: '40min',
        dependencies: ['ci-cd'],
        files: ['monitoring.yml'],
        description: 'Prometheus, Grafana, and logging configuration'
      },
      {
        id: 'security',
        name: 'Security Configuration',
        status: 'pending',
        progress: 0,
        estimatedTime: '35min',
        dependencies: ['monitoring'],
        files: ['security.yml'],
        description: 'SSL, firewalls, and security best practices'
      }
    ],
    metrics: {
      filesCreated: 4,
      linesOfCode: 350,
      testsWritten: 0,
      endpointsCreated: 0,
      modelsCreated: 0
    }
  }
]

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'completed': return <CheckCircle className="w-4 h-4 text-green-500" />
    case 'in_progress': return <Play className="w-4 h-4 text-blue-500" />
    case 'pending': return <Clock className="w-4 h-4 text-gray-400" />
    case 'blocked': return <AlertCircle className="w-4 h-4 text-red-500" />
    default: return <Pause className="w-4 h-4 text-gray-400" />
  }
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'completed': return 'bg-green-100 text-green-800'
    case 'in_progress': return 'bg-blue-100 text-blue-800'
    case 'pending': return 'bg-gray-100 text-gray-600'
    case 'blocked': return 'bg-red-100 text-red-800'
    default: return 'bg-gray-100 text-gray-600'
  }
}

export default function EnhancedBotDashboard() {
  const [selectedBot, setSelectedBot] = useState<string | null>(null)
  const [lastUpdate, setLastUpdate] = useState(new Date())

  useEffect(() => {
    const interval = setInterval(() => {
      setLastUpdate(new Date())
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  const totalProgress = ROADMAPS.reduce((acc, bot) => acc + bot.overallProgress, 0) / ROADMAPS.length
  const totalFiles = ROADMAPS.reduce((acc, bot) => acc + bot.metrics.filesCreated, 0)
  const totalLOC = ROADMAPS.reduce((acc, bot) => acc + bot.metrics.linesOfCode, 0)
  const activeBots = ROADMAPS.filter(bot => bot.status === 'active').length

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white mb-2">
            Scriby Development Hub 🚀
          </h1>
          <p className="text-purple-200">
            Real-time monitoring of parallel bot development with detailed roadmaps
          </p>
          <div className="flex items-center justify-center mt-4">
            <div className="w-3 h-3 bg-green-400 rounded-full animate-pulse mr-2"></div>
            <span className="text-green-400 font-semibold">Live</span>
            <span className="text-purple-200 ml-4">
              Last updated: {lastUpdate.toLocaleTimeString()}
            </span>
          </div>
        </div>

        {/* Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <Card className="bg-white/10 backdrop-blur-sm border-white/20">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-purple-200 text-sm">Active Bots</p>
                  <p className="text-3xl font-bold text-white">{activeBots}</p>
                  <p className="text-purple-300 text-xs">of {ROADMAPS.length} total</p>
                </div>
                <div className="w-12 h-12 bg-purple-500 rounded-lg flex items-center justify-center">
                  🤖
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-white/10 backdrop-blur-sm border-white/20">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-purple-200 text-sm">Overall Progress</p>
                  <p className="text-3xl font-bold text-white">{Math.round(totalProgress)}%</p>
                  <p className="text-purple-300 text-xs">Average completion</p>
                </div>
                <div className="w-12 h-12 bg-green-500 rounded-lg flex items-center justify-center">
                  📈
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-white/10 backdrop-blur-sm border-white/20">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-purple-200 text-sm">Total Files</p>
                  <p className="text-3xl font-bold text-white">{totalFiles}</p>
                  <p className="text-purple-300 text-xs">Across all projects</p>
                </div>
                <div className="w-12 h-12 bg-orange-500 rounded-lg flex items-center justify-center">
                  📁
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-white/10 backdrop-blur-sm border-white/20">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-purple-200 text-sm">Lines of Code</p>
                  <p className="text-3xl font-bold text-white">{totalLOC.toLocaleString()}</p>
                  <p className="text-purple-300 text-xs">Generated so far</p>
                </div>
                <div className="w-12 h-12 bg-pink-500 rounded-lg flex items-center justify-center">
                  💻
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Bot Roadmaps */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {ROADMAPS.map((bot) => (
            <Card key={bot.id} className="bg-white/10 backdrop-blur-sm border-white/20">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="text-white flex items-center gap-2">
                    <span className="text-2xl">{bot.icon}</span>
                    {bot.name}
                  </CardTitle>
                  <Badge className={getStatusColor(bot.status)}>
                    {bot.status.toUpperCase()}
                  </Badge>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-purple-200">Progress</span>
                    <span className="text-white font-semibold">{bot.overallProgress}%</span>
                  </div>
                  <Progress value={bot.overallProgress} className="h-2" />
                  <p className="text-purple-300 text-sm">{bot.currentTask}</p>
                </div>
              </CardHeader>
              <CardContent>
                {/* Metrics */}
                <div className="grid grid-cols-2 gap-4 mb-4 p-3 bg-white/5 rounded-lg">
                  <div className="text-center">
                    <p className="text-purple-200 text-xs">Files</p>
                    <p className="text-white font-bold">{bot.metrics.filesCreated}</p>
                  </div>
                  <div className="text-center">
                    <p className="text-purple-200 text-xs">LOC</p>
                    <p className="text-white font-bold">{bot.metrics.linesOfCode.toLocaleString()}</p>
                  </div>
                </div>

                {/* Task List */}
                <div className="space-y-3">
                  <h4 className="text-white font-semibold text-sm mb-2">Roadmap Tasks</h4>
                  {bot.tasks.map((task) => (
                    <div key={task.id} className="flex items-center justify-between p-2 bg-white/5 rounded">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(task.status)}
                        <div>
                          <p className="text-white text-sm font-medium">{task.name}</p>
                          <p className="text-purple-300 text-xs">{task.description}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="text-white text-sm font-semibold">{task.progress}%</p>
                        <p className="text-purple-300 text-xs">{task.estimatedTime}</p>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Files Created */}
                <div className="mt-4 p-3 bg-white/5 rounded-lg">
                  <h5 className="text-white text-sm font-semibold mb-2">Files Created</h5>
                  <div className="flex flex-wrap gap-1">
                    {bot.tasks.filter(task => task.status === 'completed').map(task => 
                      task.files.map(file => (
                        <Badge key={file} variant="outline" className="text-xs bg-green-100 text-green-800">
                          {file}
                        </Badge>
                      ))
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* System Coordination */}
        <Card className="mt-8 bg-white/10 backdrop-blur-sm border-white/20">
          <CardHeader>
            <CardTitle className="text-white">System Coordination & Integration</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-center">
              <div>
                <div className="w-16 h-16 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-2">
                  <span className="text-2xl">🔗</span>
                </div>
                <p className="text-white font-semibold">Integration Points</p>
                <p className="text-3xl font-bold text-blue-400">6</p>
                <p className="text-purple-300 text-sm">API connections ready</p>
              </div>
              <div>
                <div className="w-16 h-16 bg-red-500 rounded-full flex items-center justify-center mx-auto mb-2">
                  <span className="text-2xl">⚠️</span>
                </div>
                <p className="text-white font-semibold">Conflicts</p>
                <p className="text-3xl font-bold text-red-400">0</p>
                <p className="text-purple-300 text-sm">No blocking issues</p>
              </div>
              <div>
                <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-2">
                  <span className="text-2xl">✅</span>
                </div>
                <p className="text-white font-semibold">Status</p>
                <p className="text-3xl font-bold text-green-400">Synced</p>
                <p className="text-purple-300 text-sm">All bots coordinated</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
