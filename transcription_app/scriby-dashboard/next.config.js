/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    NEXTAUTH_URL: process.env.NEXTAUTH_URL || 'http://localhost:3000',
    NEXTAUTH_SECRET: process.env.NEXTAUTH_SECRET || 'dev-secret-key',
    BACKEND_API_URL: process.env.BACKEND_API_URL || 'http://localhost:8000',
    KEYCLOAK_URL: process.env.KEYCLOAK_URL || 'http://localhost:8080',
  },
  async rewrites() {
    return [
      {
        source: '/api/backend/:path*',
        destination: 'http://localhost:8000/api/:path*',
      },
    ];
  },
};

module.exports = nextConfig;
