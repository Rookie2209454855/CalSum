// vue.config.js
module.exports = {
  lintOnSave: false,
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080', // 后端服务器地址
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/api' // 可根据需要调整路径重写规则
        }
      }
    }
  }
}