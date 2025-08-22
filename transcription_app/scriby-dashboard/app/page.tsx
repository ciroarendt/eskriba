import EnhancedBotDashboard from '../components/EnhancedBotDashboard';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-40">
        <div className="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-pink-500/10"></div>
        <div className="absolute inset-0" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%239C92AC' fill-opacity='0.05'%3E%3Ccircle cx='30' cy='30' r='1.5'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`
        }}></div>
      </div>
      
      {/* Main Content */}
      <div className="relative z-10">
        {/* Header */}
        <div className="px-6 pt-8 pb-6">
          <div className="max-w-7xl mx-auto">
            <div className="flex items-center justify-between">
              <div>
                <div className="flex items-center space-x-3">
                  <div className="w-12 h-12 bg-gradient-to-r from-purple-500 to-pink-500 rounded-xl flex items-center justify-center shadow-lg">
                    <span className="text-2xl">🚀</span>
                  </div>
                  <div>
                    <h1 className="text-3xl font-bold bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent">
                      Scriby Development Hub
                    </h1>
                    <p className="text-gray-400 mt-1">
                      Real-time monitoring of parallel bot development
                    </p>
                  </div>
                </div>
              </div>
              
              {/* Status Indicator */}
              <div className="flex items-center space-x-4">
                <div className="flex items-center space-x-2 bg-white/10 backdrop-blur-sm rounded-full px-4 py-2 border border-white/20">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-sm text-gray-300">System Active</span>
                </div>
                <div className="bg-white/10 backdrop-blur-sm rounded-full px-4 py-2 border border-white/20">
                  <span className="text-sm text-gray-300">4 bots monitoring</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        {/* Dashboard Content */}
        <div className="px-6 pb-8">
          <div className="max-w-7xl mx-auto">
            <EnhancedBotDashboard />
          </div>
        </div>
      </div>
    </div>
  );
}
