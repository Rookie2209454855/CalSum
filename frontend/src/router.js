import Vue from 'vue';
import VueRouter from 'vue-router';
import InputView from './views/InputView.vue';
import ManageView from './views/ManageView.vue';
import UserManagementView from './views/UserManagementView.vue'; // 新增用户管理视图

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
    path: '/users',
    name: 'Users',
    component: UserManagementView,
    meta: { requiresAuth: true } // 标记为需要认证
  },
  {
    path: '/',
    redirect: '/input'
  }
];

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
});

// 路由守卫 - 检查认证状态
router.beforeEach((to, from, next) => {
  const isAuthenticated = !!localStorage.getItem('token');
  
  if (to.matched.some(record => record.meta.requiresAuth) && !isAuthenticated) {
    next('/'); // 未认证用户重定向到首页
  } else {
    next();
  }
});

export default router;