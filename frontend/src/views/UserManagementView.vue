<template>
  <div class="user-management">
    <h2>用户管理</h2>
    
    <el-card class="user-search">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-input 
            v-model="searchQuery" 
            placeholder="搜索用户名或邮箱" 
            @keyup.enter.native="searchUsers"
            clearable
          >
            <el-button slot="append" icon="el-icon-search" @click="searchUsers"></el-button>
          </el-input>
        </el-col>
        <el-col :span="12">
          <el-button type="primary" @click="loadUsers">刷新列表</el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-table 
      :data="users" 
      v-loading="loading"
      style="width: 100%" 
      stripe
      @row-click="showUserDetails"
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
    <el-dialog title="用户详情" :visible.sync="detailDialogVisible" width="600px">
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
}

.user-details p {
  margin: 10px 0;
  padding: 5px 0;
  border-bottom: 1px solid #eee;
}
</style>