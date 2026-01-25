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
    isAuthenticated: false, // 添加认证状态
    isAdmin: false // 添加管理员状态
  },
  mutations: {
    setUser(state, user) {
      state.user = user;
      state.isAuthenticated = true;
      // 检查是否是管理员（这里可以自定义判断逻辑）
      state.isAdmin = user.username === 'admin'; // 简单示例：用户名为admin的用户为管理员
    },
    clearUser(state) {
      state.user = null;
      state.isAuthenticated = false;
      state.isAdmin = false;
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
        return { 
          success: false, 
          message: error.response && error.response.data && error.response.data.error 
            ? error.response.data.error 
            : error.message 
        };
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
        return { 
          success: false, 
          message: error.response && error.response.data && error.response.data.error 
            ? error.response.data.error 
            : error.message 
        };
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
        if (error.response && error.response.status === 403) {
          localStorage.removeItem('token');
          delete axios.defaults.headers.common['Authorization'];
          commit('clearUser');
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
        // 添加字段校验，确保必要字段存在且为有效数值
        if (!food.name) {
          throw new Error('食物名称不能为空');
        }
        
        if (food.calories !== null && food.calories !== undefined) {
          if (isNaN(food.calories) || food.calories < 0) {
            throw new Error('每100克热量必须是有效的非负数');
          }
        }
        
        if (food.weight !== null && food.weight !== undefined) {
          if (isNaN(food.weight) || food.weight < 0) {
            throw new Error('重量必须是有效的非负数');
          }
        }
        
        const response = await axios.post(`${API_BASE_URL}/foods`, food);
        commit('addFood', response.data);
      } catch (error) {
        console.error('Failed to add food:', error);
        throw error;
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
    },
    
    // 获取管理员用户列表
    async fetchUsers({ commit }, params = {}) {
      try {
        const token = localStorage.getItem('token');
        const queryParams = new URLSearchParams(params).toString();
        const url = `${API_BASE_URL}/admin/users${queryParams ? '?' + queryParams : ''}`;
        
        const response = await axios.get(url, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        return response.data;
      } catch (error) {
        console.error("获取用户列表失败:", error);
        throw error;
      }
    },
    
    // 获取特定用户详情
    async fetchUserById({ commit }, userId) {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get(`${API_BASE_URL}/admin/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        return response.data;
      } catch (error) {
        console.error("获取用户详情失败:", error);
        throw error;
      }
    },
    
    // 删除用户
    async deleteUser({ commit }, userId) {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.delete(`${API_BASE_URL}/admin/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        return response.data;
      } catch (error) {
        console.error("删除用户失败:", error);
        throw error;
      }
    }
  },
  getters: {
    foods: state => state.foods,
    exercises: state => state.exercises,
    isAuthenticated: state => state.isAuthenticated,
    currentUser: state => state.user,
    isAdmin: state => state.isAdmin,
    
    // 按日期筛选食物记录
    foodsByDate: (state) => (date) => {
      return state.foods.filter(food => {
        // 如果后端返回的timestamp是ISO格式，我们需要提取日期部分
        const foodDate = food.date || (food.timestamp ? new Date(food.timestamp).toISOString().split('T')[0] : '');
        return foodDate === date;
      });
    },
    
    // 按日期筛选运动记录
    exercisesByDate: (state) => (date) => {
      return state.exercises.filter(exercise => {
        // 如果后端返回的timestamp是ISO格式，我们需要提取日期部分
        const exerciseDate = exercise.date || (exercise.timestamp ? new Date(exercise.timestamp).toISOString().split('T')[0] : '');
        return exerciseDate === date;
      });
    },
    
    // 计算指定日期的总摄入热量
    totalIntakeByDate: (state, getters) => (date) => {
      const foods = getters.foodsByDate(date);
      return foods.reduce((total, food) => {
        // 确保有正确的calories字段
        return total + (food.calories || 0);
      }, 0);
    },
    
    // 计算指定日期的总消耗热量
    totalBurnedByDate: (state, getters) => (date) => {
      const exercises = getters.exercisesByDate(date);
      return exercises.reduce((total, exercise) => {
        // 确保有正确的caloriesBurned字段
        return total + (exercise.caloriesBurned || 0);
      }, 0);
    }
  }
});