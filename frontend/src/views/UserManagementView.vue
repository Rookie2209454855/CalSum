<template>
  <div class="user-management">
    <h2>用户管理</h2>

    <el-card class="user-search">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="24" :md="12">
          <el-input
            v-model="searchQuery"
            placeholder="搜索用户名或邮箱"
            @keyup.enter.native="searchUsers"
            clearable
            style="width: 100%;">
            <el-button slot="append" icon="el-icon-search" @click="searchUsers"></el-button>
          </el-input>
        </el-col>
        <el-col :xs="24" :sm="24" :md="12">
          <el-button type="primary" @click="loadUsers" style="width: 100%; margin-top: 10px; margin-bottom: 10px;">刷新列表</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 桌面端表格 -->
    <el-table
      :data="users"
      v-loading="loading"
      style="width: 100%"
      stripe
      @row-click="showUserDetails"
      class="desktop-table"
    >
      <el-table-column prop="username" label="用户名" width="150"></el-table-column>
      <el-table-column prop="email" label="邮箱" width="200"></el-table-column>
      <el-table-column prop="created_at" label="注册时间" width="180">
        <template slot-scope="scope">
          {{ formatDate(scope.row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column label="数据统计" width="200">
        <template slot-scope="scope">
          食物记录: {{ scope.row.foods_count || 0 }} | 运动记录: {{ scope.row.exercises_count || 0 }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template slot-scope="scope">
          <el-button size="mini" @click.stop="showUserDetails(scope.row)">详情</el-button>
          <el-popconfirm
            title="确定要删除此用户及其所有数据吗？"
            @confirm="deleteUser(scope.row.id)"
          >
            <el-button size="mini" type="danger" slot="reference">删除</el-button>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <!-- 移动端卡片列表 -->
    <div class="mobile-card-list">
      <el-card v-for="user in users" :key="user.id" class="user-card" shadow="hover">
        <div class="card-header">
          <span class="user-name">{{ user.username }}</span>
          <el-tag type="info" size="small">{{ user.email }}</el-tag>
        </div>
        <div class="card-content">
          <div class="info-item">
            <span class="label">注册时间:</span>
            <span class="value">{{ formatDate(user.created_at) }}</span>
          </div>
          <div class="info-item">
            <span class="label">食物记录:</span>
            <span class="value">{{ user.foods_count || 0 }}</span>
          </div>
          <div class="info-item">
            <span class="label">运动记录:</span>
            <span class="value">{{ user.exercises_count || 0 }}</span>
          </div>
        </div>
        <div class="card-actions">
          <el-button type="primary" size="small" @click="showUserDetails(user)">详情</el-button>
          <el-popconfirm
            title="确定要删除此用户及其所有数据吗？"
            @confirm="deleteUser(user.id)"
          >
            <el-button type="danger" size="small" slot="reference">删除</el-button>
          </el-popconfirm>
        </div>
      </el-card>
    </div>

    <!-- 分页 -->
    <el-pagination
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      :current-page="currentPage"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="pageSize"
      layout="total, sizes, prev, pager, next, jumper"
      :total="totalUsers">
    </el-pagination>

    <!-- 用户详情对话框 -->
    <el-dialog title="用户详情" :visible.sync="detailDialogVisible" width="600px" class="desktop-dialog">
      <div v-if="selectedUser" class="user-details">
        <p><strong>用户名:</strong> {{ selectedUser.username }}</p>
        <p><strong>邮箱:</strong> {{ selectedUser.email }}</p>
        <p><strong>注册时间:</strong> {{ formatDate(selectedUser.created_at) }}</p>
        <p><strong>食物记录数量:</strong> {{ selectedUser.foods_count || 0 }}</p>
        <p><strong>运动记录数量:</strong> {{ selectedUser.exercises_count || 0 }}</p>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </span>
    </el-dialog>

    <!-- 用户详情对话框 - 移动端 -->
    <el-dialog title="用户详情" :visible.sync="detailDialogVisible" width="90%" class="mobile-dialog" :modal-append-to-body="false" :close-on-click-modal="false" :lock-scroll="true">
      <div v-if="selectedUser" class="user-details mobile-user-details">
        <p><strong>用户名:</strong> {{ selectedUser.username }}</p>
        <p><strong>邮箱:</strong> {{ selectedUser.email }}</p>
        <p><strong>注册时间:</strong> {{ formatDate(selectedUser.created_at) }}</p>
        <p><strong>食物记录数量:</strong> {{ selectedUser.foods_count || 0 }}</p>
        <p><strong>运动记录数量:</strong> {{ selectedUser.exercises_count || 0 }}</p>
      </div>
      <span slot="footer" class="dialog-footer" style="display: flex; gap: 10px;">
        <el-button @click="detailDialogVisible = false" style="flex: 1;">关闭</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'UserManagementView',
  data() {
    return {
      users: [],
      loading: false,
      searchQuery: '',
      currentPage: 1,
      pageSize: 10,
      totalUsers: 0,
      detailDialogVisible: false,
      selectedUser: null
    }
  },
  async mounted() {
    await this.loadUsers();
  },
  methods: {
    async loadUsers() {
      this.loading = true;
      try {
        const response = await axios.get('/api/admin/users', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          params: {
            page: this.currentPage,
            limit: this.pageSize,
            search: this.searchQuery
          }
        });
        
        this.users = response.data.users;
        this.totalUsers = response.data.total;
      } catch (error) {
        console.error('Failed to load users:', error);
        this.$message.error('加载用户列表失败: ' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : error.message));
      } finally {
        this.loading = false;
      }
    },
    
    async searchUsers() {
      this.currentPage = 1; // 重置到第一页
      await this.loadUsers();
    },
    
    async deleteUser(userId) {
      try {
        await axios.delete(`/api/admin/users/${userId}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        
        this.$message.success('用户删除成功');
        await this.loadUsers(); // Refresh the list
      } catch (error) {
        console.error('Failed to delete user:', error);
        this.$message.error('删除用户失败: ' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : error.message));
      }
    },
    
    async showUserDetails(user) {
      try {
        const response = await axios.get(`/api/admin/users/${user.id}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        
        this.selectedUser = response.data;
        this.detailDialogVisible = true;
      } catch (error) {
        console.error('Failed to load user details:', error);
        this.$message.error('加载用户详情失败: ' + (error.response && error.response.data && error.response.data.error ? error.response.data.error : error.message));
      }
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleString('zh-CN');
    },
    
    handleSizeChange(val) {
      this.pageSize = val;
      this.loadUsers();
    },
    
    handleCurrentChange(val) {
      this.currentPage = val;
      this.loadUsers();
    }
  }
}
</script>

<style scoped>
.user-management {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.user-search {
  margin-bottom: 20px;
  padding: 15px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.user-search:hover {
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.user-details p {
  margin: 10px 0;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
  font-size: 15px;
  line-height: 1.8;
}

/* 桌面端表格 - 默认显示 */
.desktop-table {
  display: table;
}

/* 移动端卡片列表 - 默认隐藏 */
.mobile-card-list {
  display: none;
}

/* 用户卡片美化 */
.user-card {
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.user-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  transform: translateY(-4px);
}

.user-card:active {
  transform: translateY(-2px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 2px solid #f0f0f0;
}

.user-name {
  font-weight: bold;
  font-size: 17px;
  color: #667eea;
  letter-spacing: 0.3px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-radius: 6px;
  background: linear-gradient(90deg, #f8f9fa 0%, #ffffff 100%);
}

.info-item .label {
  color: #909399;
  font-size: 14px;
  font-weight: 500;
}

.info-item .value {
  color: #667eea;
  font-size: 15px;
  font-weight: 600;
}

.card-actions {
  display: flex;
  gap: 10px;
  margin-top: 12px;
}

.card-actions .el-button {
  border-radius: 8px;
  font-weight: 500;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.card-actions .el-button--primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.card-actions .el-button--danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(235, 51, 73, 0.3);
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .user-management {
    padding: 10px;
    max-width: 100%;
  }

  .user-search {
    padding: 10px;
  }

  /* 隐藏桌面表格 */
  .desktop-table {
    display: none;
  }

  /* 显示移动端卡片列表 */
  .mobile-card-list {
    display: block;
  }

  .user-card {
    margin-bottom: 15px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
  }

  .user-name {
    font-weight: bold;
    font-size: 16px;
    color: #333;
  }

  .card-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 10px;
  }

  .info-item {
    display: flex;
    justify-content: space-between;
  }

  .info-item .label {
    color: #909399;
    font-size: 14px;
  }

  .info-item .value {
    color: #303133;
    font-size: 14px;
    font-weight: 500;
  }

  .card-actions {
    display: flex;
    gap: 10px;
  }

  .card-actions .el-button {
    flex: 1;
  }

  /* 分页适配 */
  .el-pagination {
    margin-top: 20px;
    text-align: center;
  }

  .el-pagination .el-pagination__sizes,
  .el-pagination .el-pagination__jump {
    display: none;
  }

  /* 对话框适配 */
  .el-dialog {
    width: 90% !important;
    margin-top: 5vh !important;
    border-radius: 12px;
  }

  .el-dialog__header {
    padding: 15px 20px;
    background-color: #f5f7fa;
    border-radius: 12px 12px 0 0;
  }

  .el-dialog__title {
    font-size: 16px;
    font-weight: 600;
  }

  .el-dialog__body {
    padding: 20px;
    max-height: 60vh;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
  }

  .el-dialog__footer {
    padding: 15px 20px;
    border-top: 1px solid #eee;
  }

  /* 用户详情移动端适配 */
  .mobile-user-details p {
    padding: 10px 0;
    font-size: 14px;
  }

  .mobile-user-details strong {
    display: inline-block;
    min-width: 100px;
    color: #606266;
  }

  .dialog-footer .el-button {
    height: 40px;
    font-size: 15px;
    border-radius: 8px;
  }
}

@media screen and (max-width: 480px) {
  .user-management {
    padding: 8px;
  }

  .user-search {
    padding: 8px;
  }

  .user-card {
    margin-bottom: 10px;
  }

  .user-card .el-card__body {
    padding: 10px;
  }

  .user-name {
    font-size: 15px;
  }

  .info-item .label,
  .info-item .value {
    font-size: 13px;
  }

  .card-actions .el-button {
    font-size: 12px;
    height: 36px;
  }

  /* 对话框优化 */
  .el-dialog {
    width: 92% !important;
  }

  .el-dialog__header {
    padding: 12px 15px;
  }

  .el-dialog__body {
    padding: 15px;
  }

  .el-dialog__footer {
    padding: 12px 15px;
  }

  .el-dialog__title {
    font-size: 15px;
  }

  .mobile-user-details p {
    padding: 8px 0;
    font-size: 13px;
  }

  .dialog-footer .el-button {
    height: 38px;
    font-size: 14px;
  }
}

/* 超小屏手机适配 */
@media screen and (max-width: 360px) {
  .el-dialog {
    width: 95% !important;
  }

  .el-dialog__header {
    padding: 10px 12px;
  }

  .el-dialog__title {
    font-size: 14px;
  }

  .el-dialog__body {
    padding: 12px;
  }

  .el-dialog__footer {
    padding: 10px 12px;
  }

  .dialog-footer .el-button {
    height: 36px;
    font-size: 13px;
  }
}

/* 横屏对话框优化 */
@media screen and (max-height: 500px) and (orientation: landscape) {
  .el-dialog {
    max-height: 90vh;
  }

  .el-dialog__body {
    max-height: 50vh;
    padding: 12px;
  }

  .el-dialog__header {
    padding: 10px 15px;
  }

  .el-dialog__footer {
    padding: 10px 15px;
  }

  .dialog-footer .el-button {
    height: 36px;
  }
}

/* 触控优化 */
@media (hover: none) and (pointer: coarse) {
  /* 卡片按钮优化 */
  .card-actions .el-button {
    min-height: 44px;
  }

  /* 对话框按钮优化 */
  .dialog-footer .el-button {
    min-height: 48px;
    font-size: 15px;
  }
}

/* 桌面端隐藏移动对话框 */
@media screen and (min-width: 769px) {
  .mobile-dialog {
    display: none !important;
  }
}
</style>