'use client';

import React from 'react';
import Link from 'next/link';
import { 
  Activity, 
  BarChart3, 
  Settings, 
  Users, 
  DollarSign,
  Bot
} from 'lucide-react';

const navigation = [
  { name: 'Bot Monitoring', href: '/', icon: Bot, current: true },
  { name: 'Analytics', href: '/analytics', icon: BarChart3, current: false },
  { name: 'Users', href: '/users', icon: Users, current: false },
  { name: 'Billing', href: '/billing', icon: DollarSign, current: false },
  { name: 'Settings', href: '/settings', icon: Settings, current: false },
];

function classNames(...classes: string[]) {
  return classes.filter(Boolean).join(' ');
}

export function Sidebar() {
  return (
    <div className="flex h-full w-64 flex-col bg-gray-900">
      {/* Logo */}
      <div className="flex h-16 flex-shrink-0 items-center px-4">
        <div className="flex items-center">
          <Activity className="h-8 w-8 text-indigo-500" />
          <span className="ml-2 text-xl font-bold text-white">Scriby</span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-2 py-4">
        {navigation.map((item) => (
          <Link
            key={item.name}
            href={item.href}
            className={classNames(
              item.current
                ? 'bg-gray-800 text-white'
                : 'text-gray-300 hover:bg-gray-700 hover:text-white',
              'group flex items-center px-2 py-2 text-sm font-medium rounded-md'
            )}
          >
            <item.icon
              className={classNames(
                item.current ? 'text-gray-300' : 'text-gray-400 group-hover:text-gray-300',
                'mr-3 flex-shrink-0 h-6 w-6'
              )}
              aria-hidden="true"
            />
            {item.name}
          </Link>
        ))}
      </nav>

      {/* Status */}
      <div className="flex-shrink-0 p-4">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <div className="h-2 w-2 bg-green-400 rounded-full animate-pulse"></div>
          </div>
          <div className="ml-3">
            <p className="text-sm font-medium text-white">System Active</p>
            <p className="text-xs text-gray-400">4 bots monitoring</p>
          </div>
        </div>
      </div>
    </div>
  );
}
