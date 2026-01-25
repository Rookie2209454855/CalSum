<template>
  <div class="manage-view">
    <food-list 
      :foods="foods" 
      @delete-food="handleDeleteFood" 
      @update-food="handleUpdateFood" 
    />
    <exercise-list 
      :exercises="exercises" 
      @delete-exercise="handleDeleteExercise" 
      @update-exercise="handleUpdateExercise" 
    />
    <daily-summary 
      :foods="foods" 
      :exercises="exercises" 
      :date="currentDate" 
    />
    <export-data 
      :foods="foods" 
      :exercises="exercises" 
    />
  </div>
</template>

<script>
import FoodList from '@/components/FoodList.vue';
import ExerciseList from '@/components/ExerciseList.vue';
import DailySummary from '@/components/DailySummary.vue';
import ExportData from '@/components/ExportData.vue';

export default {
  name: 'ManageView',
  components: {
    FoodList,
    ExerciseList,
    DailySummary,
    ExportData
  },
  data() {
    return {
      currentDate: new Date().toISOString().slice(0, 10)
    };
  },
  computed: {
    foods() {
      return this.$store.getters.foods;
    },
    exercises() {
      return this.$store.getters.exercises;
    }
  },
  methods: {
    handleDeleteFood(id) {
      this.$store.commit('deleteFood', id);
      this.$store.dispatch('saveToLocalStorage');
    },
    handleDeleteExercise(id) {
      this.$store.commit('deleteExercise', id);
      this.$store.dispatch('saveToLocalStorage');
    },
    handleUpdateFood(updatedFood) {
      this.$store.commit('updateFood', updatedFood);
      this.$store.dispatch('saveToLocalStorage');
    },
    handleUpdateExercise(updatedExercise) {
      this.$store.commit('updateExercise', updatedExercise);
      this.$store.dispatch('saveToLocalStorage');
    }
  }
};
</script>

<style scoped>
.manage-view {
  max-width: 1000px;
  margin: 0 auto;
}
</style>
<template>
  <div class="input-view">
    <food-input @add-food="handleAddFood" />
    <exercise-input @add-exercise="handleAddExercise" />
  </div>
</template>

<script>
import FoodInput from '@/components/FoodInput.vue';
import ExerciseInput from '@/components/ExerciseInput.vue';

export default {
  name: 'InputView',
  components: {
    FoodInput,
    ExerciseInput
  },
  methods: {
    handleAddFood(food) {
      this.$store.commit('addFood', { ...food, id: Date.now() });
      this.$store.dispatch('saveToLocalStorage');
    },
    handleAddExercise(exercise) {
      this.$store.commit('addExercise', { ...exercise, id: Date.now() });
      this.$store.dispatch('saveToLocalStorage');
    }
  }
};
</script>

<style scoped>
.input-view {
  max-width: 800px;
  margin: 0 auto;
}
</style>
import Vue from 'vue';
import VueRouter from 'vue-router';
import InputView from '../views/InputView.vue';
import ManageView from '../views/ManageView.vue';

Vue.use(VueRouter);

const routes = [
  {
    path: '/input',
    name: 'Input',
    component: InputView
  },
  {
    path: '/manage',
    name: 'Manage',
    component: ManageView
  },
  {
    path: '/',
    redirect: '/input'
  }
];

export default new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
});
import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios'; // 引入axios用于API请求

Vue.use(Vuex);

// 定义API基础URL，可以根据环境变量调整
const API_BASE_URL = process.env.VUE_APP_API_URL || 'http://localhost:8080/api';

export default new Vuex.Store({
  state: {
    user: null, // 添加用户状态
    foods: [],
    exercises: [],
    isAuthenticated: false // 添加认证状态
  },
  mutations: {
    setUser(state, user) {
      state.user = user;
      state.isAuthenticated = true;
    },
    clearUser(state) {
      state.user = null;
      state.isAuthenticated = false;
    },
    setFoods(state, foods) {
      state.foods = foods;
    },
    setExercises(state, exercises) {
      state.exercises = exercises;
    },
    addFood(state, food) {
      state.foods.push(food);
    },
    addExercise(state, exercise) {
      state.exercises.push(exercise);
    },
    deleteFood(state, id) {
      state.foods = state.foods.filter(food => food.id !== id);
    },
    deleteExercise(state, id) {
      state.exercises = state.exercises.filter(exercise => exercise.id !== id);
    },
    updateFood(state, updatedFood) {
      const index = state.foods.findIndex(f => f.id === updatedFood.id);
      if (index !== -1) {
        state.foods.splice(index, 1, updatedFood);
      }
    },
    updateExercise(state, updatedExercise) {
      const index = state.exercises.findIndex(e => e.id === updatedExercise.id);
      if (index !== -1) {
        state.exercises.splice(index, 1, updatedExercise);
      }
    }
  },
  actions: {
    // 用户注册
    async register({ commit }, userData) {
      try {
        const response = await axios.post(`${API_BASE_URL}/register`, userData);
        const { token, ...user } = response.data;
        
        // 保存token到localStorage
        localStorage.setItem('token', token);
        // 设置axios默认header
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        
        commit('setUser', user);
        return { success: true, user };
      } catch (error) {
        return { success: false, message: error.response?.data?.error || error.message };
      }
    },
    
    // 用户登录
    async login({ commit }, userData) {
      try {
        const response = await axios.post(`${API_BASE_URL}/login`, userData);
        const { token, ...user } = response.data;
        
        // 保存token到localStorage
        localStorage.setItem('token', token);
        // 设置axios默认header
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        
        commit('setUser', user);
        return { success: true, user };
      } catch (error) {
        return { success: false, message: error.response?.data?.error || error.message };
      }
    },
    
    // 用户登出
    logout({ commit }) {
      // 清除token
      localStorage.removeItem('token');
      delete axios.defaults.headers.common['Authorization'];
      commit('clearUser');
    },
    
    // 获取用户资料
    async fetchProfile({ commit }) {
      try {
        const token = localStorage.getItem('token');
        if (!token) return;
        
        // 设置axios默认header
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        
        const response = await axios.get(`${API_BASE_URL}/profile`);
        commit('setUser', response.data);
      } catch (error) {
        console.error('Failed to fetch profile:', error);
        // 如果获取用户资料失败，可能是token过期，清除用户状态
        if (error.response?.status === 403) {
          localStorage.removeItem('token');
          delete axios.defaults.headers.common['Authorization'];
        }
      }
    },
    
    // 从API获取数据
    async fetchData({ commit }) {
      try {
        const response = await axios.get(`${API_BASE_URL}/data`);
        commit('setFoods', response.data.foods);
        commit('setExercises', response.data.exercises);
      } catch (error) {
        console.error('Failed to fetch data:', error);
      }
    },
    
    // 添加食物
    async addFood({ commit }, food) {
      try {
        const response = await axios.post(`${API_BASE_URL}/foods`, food);
        commit('addFood', response.data);
      } catch (error) {
        console.error('Failed to add food:', error);
      }
    },
    
    // 更新食物
    async updateFood({ commit }, updatedFood) {
      try {
        const response = await axios.put(`${API_BASE_URL}/foods/${updatedFood.id}`, updatedFood);
        commit('updateFood', response.data);
      } catch (error) {
        console.error('Failed to update food:', error);
      }
    },
    
    // 删除食物
    async deleteFood({ commit }, id) {
      try {
        await axios.delete(`${API_BASE_URL}/foods/${id}`);
        commit('deleteFood', id);
      } catch (error) {
        console.error('Failed to delete food:', error);
      }
    },
    
    // 添加运动
    async addExercise({ commit }, exercise) {
      try {
        const response = await axios.post(`${API_BASE_URL}/exercises`, exercise);
        commit('addExercise', response.data);
      } catch (error) {
        console.error('Failed to add exercise:', error);
      }
    },
    
    // 更新运动
    async updateExercise({ commit }, updatedExercise) {
      try {
        const response = await axios.put(`${API_BASE_URL}/exercises/${updatedExercise.id}`, updatedExercise);
        commit('updateExercise', response.data);
      } catch (error) {
        console.error('Failed to update exercise:', error);
      }
    },
    
    // 删除运动
    async deleteExercise({ commit }, id) {
      try {
        await axios.delete(`${API_BASE_URL}/exercises/${id}`);
        commit('deleteExercise', id);
      } catch (error) {
        console.error('Failed to delete exercise:', error);
      }
    }
  },
  getters: {
    foods: state => state.foods,
    exercises: state => state.exercises,
    isAuthenticated: state => state.isAuthenticated,
    currentUser: state => state.user,
    isAdmin: state => state.user?.role === 'admin'
  }
});
<template>
  <div id="app">
    <el-container>
      <el-header>
        <div class="header-content">
          <h1>食物热量与运动追踪器</h1>
          <div class="user-info" v-if="isAuthenticated">
            <span>欢迎, {{ currentUser.username }}!</span>
            <el-button type="text" @click="logout">退出</el-button>
          </div>
          <div class="auth-buttons" v-else>
            <el-button type="primary" @click="showLoginDialog = true">登录</el-button>
            <el-button @click="showRegisterDialog = true">注册</el-button>
          </div>
        </div>
      </el-header>
      <el-main v-if="isAuthenticated">
        <el-menu :default-active="$route.path" mode="horizontal" router>
          <el-menu-item index="/input">录入数据</el-menu-item>
          <el-menu-item index="/manage">管理数据</el-menu-item>
          <el-menu-item index="/users" v-if="isAdmin">用户管理</el-menu-item>
        </el-menu>
        <router-view/>
      </el-main>
      <el-main v-else>
        <div class="welcome-message">
          <h2>欢迎使用食物热量与运动追踪器</h2>
          <p>请登录或注册以开始记录您的饮食和运动数据</p>
        </div>
      </el-main>
      
      <!-- 登录对话框 -->
      <el-dialog title="用户登录" :visible.sync="showLoginDialog" width="400px">
        <el-form :model="loginForm" :rules="formRules" ref="loginForm" label-width="80px">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="loginForm.username" placeholder="请输入用户名"></el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input type="password" v-model="loginForm.password" placeholder="请输入密码"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="showLoginDialog = false">取消</el-button>
          <el-button type="primary" @click="handleLogin">登录</el-button>
        </div>
      </el-dialog>
      
      <!-- 注册对话框 -->
      <el-dialog title="用户注册" :visible.sync="showRegisterDialog" width="400px">
        <el-form :model="registerForm" :rules="formRules" ref="registerForm" label-width="80px">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="registerForm.username" placeholder="请输入用户名"></el-input>
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input v-model="registerForm.email" placeholder="请输入邮箱"></el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input type="password" v-model="registerForm.password" placeholder="请输入密码"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="showRegisterDialog = false">取消</el-button>
          <el-button type="primary" @click="handleRegister">注册</el-button>
        </div>
      </el-dialog>
      
    </el-container>
  </div>
</template>

<script>
import axios from 'axios'; // 导入axios

export default {
  name: 'App',
  data() {
    return {
      showLoginDialog: false,
      showRegisterDialog: false,
      loginForm: {
        username: '',
        password: ''
      },
      registerForm: {
        username: '',
        email: '',
        password: ''
      },
      formRules: {
        username: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        email: [
          { required: true, message: '请输入邮箱', trigger: 'blur' },
          { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输入密码', trigger: 'blur' },
          { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    isAuthenticated() {
      return this.$store.getters.isAuthenticated;
    },
    currentUser() {
      return this.$store.getters.currentUser;
    },
    isAdmin() {
      return this.$store.getters.isAdmin;
    }
  },
  async mounted() {
    // 检查是否有存储的token，如果有则尝试获取用户信息
    const token = localStorage.getItem('token');
    if (token) {
      await this.$store.dispatch('fetchProfile');
      // 如果用户已认证，则获取数据
      if (this.$store.getters.isAuthenticated) {
        await this.$store.dispatch('fetchData');
      }
    }
  },
  methods: {
    async handleLogin() {
      const valid = await this.$refs.loginForm.validate().catch(() => false);
      if (!valid) return;
      
      const result = await this.$store.dispatch('login', this.loginForm);
      if (result.success) {
        this.showLoginDialog = false;
        this.$message.success(`欢迎回来，${result.user.username}！`);
        // 登录成功后获取数据
        await this.$store.dispatch('fetchData');
      } else {
        this.$message.error(result.message || '登录失败');
      }
    },
    
    async handleRegister() {
      const valid = await this.$refs.registerForm.validate().catch(() => false);
      if (!valid) return;
      
      const result = await this.$store.dispatch('register', this.registerForm);
      if (result.success) {
        this.showRegisterDialog = false;
        this.$message.success('注册成功，请登录！');
      } else {
        this.$message.error(result.message || '注册失败');
      }
    },
    
    logout() {
      this.$store.dispatch('logout');
      this.$message.success('已退出登录');
    }
  }
}
</script>

<style>
.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-info, .auth-buttons {
  display: flex;
  align-items: center;
}

.welcome-message {
  text-align: center;
  padding: 40px 20px;
}

.welcome-message h2 {
  color: #333;
  margin-bottom: 20px;
}

.welcome-message p {
  color: #666;
  font-size: 16px;
}
</style>
