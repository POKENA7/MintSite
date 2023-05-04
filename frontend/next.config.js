const { default: next } = require('next')

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
}

module.exports = nextConfig

// module.exports = {
//   webpack: (config, { isServer }) => {
//     if (!isServer) {
//       config.resolve.fallback.fs = false
//       config.resolve.fallback.net = false
//       config.resolve.fallback.tls = false
//     }
//     return config
//   },
// }
