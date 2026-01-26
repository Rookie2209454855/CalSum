<template>
  <el-card class="box-card" header="添加运动记录" style="margin-bottom: 20px;">
    <el-form :model="form" label-width="100px" @submit.native.prevent class="exercise-form">
      <!-- 桌面端和宽屏布局 -->
      <el-row :gutter="20" class="desktop-layout">
        <el-col :xs="24" :sm="12" :md="6">
          <el-form-item label="运动项目">
            <el-input v-model="form.name" placeholder="请输入运动项目" style="width: 100%;"></el-input>
          </el-form-item>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6">
          <el-form-item label="组数">
            <el-input-number v-model="form.sets" :min="1" :step="1" placeholder="组" style="width: 100%;"></el-input-number>
          </el-form-item>
        </el-col>
        <el-col :xs="12" :sm="12" :md="6">
          <el-form-item label="是否完成">
            <el-switch
              v-model="form.completed"
              active-text="是"
              inactive-text="否">
            </el-switch>
          </el-form-item>
        </el-col>
        <el-col :xs="24" :sm="12" :md="6">
          <el-form-item label="消耗热量">
            <el-input-number v-model="form.caloriesBurned" :min="0" :step="50" placeholder="千卡" style="width: 100%;"></el-input-number>
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 移动端紧凑布局 -->
      <div class="mobile-layout">
        <el-form-item label="运动项目">
          <el-input v-model="form.name" placeholder="请输入运动项目" size="small"></el-input>
        </el-form-item>

        <div class="mobile-row">
          <div class="mobile-item">
            <label class="mobile-label">组数</label>
            <el-input-number v-model="form.sets" :min="1" :step="1" size="small" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </div>
          <div class="mobile-item">
            <label class="mobile-label">消耗热量</label>
            <el-input-number v-model="form.caloriesBurned" :min="0" :step="50" size="small" placeholder="千卡" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </div>
        </div>

        <el-form-item label="完成状态">
          <div class="switch-wrapper">
            <el-switch
              v-model="form.completed"
              active-text="已完成"
              inactive-text="未完成">
            </el-switch>
          </div>
        </el-form-item>

        <el-form-item label="日期">
          <el-date-picker
            v-model="form.date"
            type="date"
            placeholder="选择日期"
            format="yyyy-MM-dd"
            value-format="yyyy-MM-dd"
            size="small"
            style="width: 100%;">
          </el-date-picker>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="addExercise" size="small" style="width: 100%;" icon="el-icon-plus" class="submit-btn">添加记录</el-button>
        </el-form-item>
      </div>
    </el-form>
  </el-card>
</template>

<script>
export default {
  name: 'ExerciseInput',
  data() {
    return {
      form: {
        name: '',
        sets: 1,
        completed: true,
        caloriesBurned: null,
        date: new Date().toISOString().slice(0, 10)
      }
    }
  },
  computed: {
    mobileSize() {
      return window.innerWidth <= 360 ? 'right' : 'right';
    }
  },
  methods: {
    addExercise() {
      if (!this.form.name || !this.form.date) {
        this.$message.error('请填写必要信息');
        return;
      }

      this.$store.dispatch('addExercise', { ...this.form, id: Date.now() });
      this.$message.success('运动记录添加成功');

      // 重置表单
      this.form = {
        name: '',
        sets: 1,
        completed: true,
        caloriesBurned: null,
        date: new Date().toISOString().slice(0, 10)
      };
    }
  }
}
</script>

<style scoped>
.box-card {
  margin-bottom: 20px;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.box-card:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.exercise-form .el-form-item {
  margin-bottom: 18px;
}

/* 桌面端布局 - 默认显示 */
.desktop-layout {
  display: flex;
  flex-wrap: wrap;
}

/* 确保所有表单项对齐 */
.exercise-form .el-form-item__label {
  text-align: right;
  padding-right: 12px;
}

.exercise-form .el-input__inner,
.exercise-form .el-input-number__inner,
.exercise-form .el-date-editor .el-input__inner {
  height: 40px;
  line-height: 40px;
}

/* 移动端紧凑布局 - 默认隐藏 */
.mobile-layout {
  display: none;
}

/* 移动端表单项对齐 */
.mobile-layout .el-form-item__label {
  text-align: left;
  padding-right: 12px;
  padding-left: 0;
}

.mobile-layout .el-input__inner,
.mobile-layout .el-input-number__inner,
.mobile-layout .el-date-editor .el-input__inner {
  height: 40px;
  line-height: 40px;
}

/* 输入框美化 */
.el-input__inner,
.el-input-number__inner,
.el-select .el-input__inner {
  border-radius: 8px;
  border: 2px solid #dcdfe6;
  transition: all 0.3s ease;
}

.el-input__inner:focus,
.el-input-number__inner:focus,
.el-select .el-input__inner:focus {
  border-color: #764ba2;
  box-shadow: 0 0 0 3px rgba(118, 75, 162, 0.1);
}

/* 开关美化 */
.el-switch__core {
  border: 2px solid #dcdfe6;
  transition: all 0.3s ease;
}

.el-switch.is-checked .el-switch__core {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  border-color: #667eea;
}

/* 移动端适配 - 平板和小屏手机 */
@media screen and (max-width: 768px) {
  .box-card {
    margin-bottom: 15px;
    border-radius: 8px;
  }

  .box-card .el-card__header {
    padding: 12px 15px;
    font-size: 16px;
    font-weight: 600;
  }

  .box-card .el-card__body {
    padding: 15px;
  }

  /* 隐藏桌面布局 */
  .desktop-layout {
    display: none;
  }

  /* 显示移动端紧凑布局 */
  .mobile-layout {
    display: block;
  }

  .mobile-layout .el-form-item {
    margin-bottom: 16px;
  }

  .mobile-layout .el-form-item__label {
    width: 75px !important;
    font-size: 14px;
    line-height: 32px;
  }

  .mobile-layout .el-input__inner {
    font-size: 16px; /* 防止iOS自动缩放 */
    height: 36px;
    line-height: 36px;
  }

  /* 移动端横向排列区域 */
  .mobile-row {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 16px;
    margin-top: 8px;
  }

  .mobile-item {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .mobile-label {
    font-size: 14px;
    color: #606266;
    white-space: nowrap;
    min-width: 45px;
  }

  /* 输入数字控件优化 */
  .mobile-item .el-input-number {
    flex: 1;
  }

  .mobile-item .el-input-number .el-input__inner {
    font-size: 16px;
    padding: 5px 36px 5px 10px;
    height: 36px;
    line-height: 36px;
    border-radius: 6px;
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__increase,
  .mobile-item .el-input-number.is-controls-right .el-input-number__decrease {
    width: 28px;
    line-height: 17px;
    border-radius: 0 4px 4px 0;
    background-color: #f5f7fa;
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__increase {
    top: 0;
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__decrease {
    bottom: 0;
    top: auto;
  }

  /* 开关组件优化 */
  .switch-wrapper {
    width: 100%;
    display: flex;
    align-items: center;
    padding: 4px 0;
  }

  .switch-wrapper .el-switch {
    transform: scale(1.1);
    transform-origin: left center;
  }

  .switch-wrapper .el-switch__label {
    font-size: 13px;
    margin-left: 8px;
  }

  /* 日期选择器优化 */
  .mobile-layout .el-date-editor {
    width: 100%;
  }

  .mobile-layout .el-date-editor .el-input__inner {
    padding-left: 30px;
  }

  /* 提交按钮优化 */
  .submit-btn {
    margin-top: 8px;
    height: 44px !important;
    font-size: 16px !important;
    font-weight: 500;
    border-radius: 22px;
    letter-spacing: 1px;
  }

  .submit-btn:active {
    transform: scale(0.98);
  }
}

/* 小屏手机适配 */
@media screen and (max-width: 480px) {
  .box-card .el-card__body {
    padding: 12px;
  }

  .mobile-layout .el-form-item {
    margin-bottom: 14px;
  }

  .mobile-layout .el-form-item__label {
    width: 70px !important;
    font-size: 13px;
    line-height: 32px;
  }

  .mobile-layout .el-input__inner {
    height: 34px;
    line-height: 34px;
  }

  .mobile-row {
    gap: 10px;
    margin-bottom: 14px;
  }

  .mobile-item {
    gap: 6px;
  }

  .mobile-label {
    font-size: 13px;
    min-width: 42px;
  }

  .mobile-item .el-input-number .el-input__inner {
    padding: 5px 34px 5px 8px;
    height: 34px;
    line-height: 34px;
    font-size: 15px;
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__increase,
  .mobile-item .el-input-number.is-controls-right .el-input-number__decrease {
    width: 26px;
    line-height: 16px;
  }

  .switch-wrapper .el-switch__label {
    font-size: 12px;
    margin-left: 6px;
  }

  .submit-btn {
    height: 42px !important;
    font-size: 15px !important;
  }
}

/* 超小屏手机适配 */
@media screen and (max-width: 360px) {
  .box-card .el-card__header {
    padding: 10px 12px;
    font-size: 15px;
  }

  .box-card .el-card__body {
    padding: 10px;
  }

  .mobile-row {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
    margin-bottom: 12px;
  }

  .mobile-item {
    width: 100%;
    justify-content: space-between;
  }

  .mobile-item .el-input-number {
    flex: 1;
  }

  .mobile-item .el-input-number .el-input__inner {
    padding: 5px 32px 5px 10px;
    height: 34px;
  }

  .mobile-label {
    min-width: 48px;
    font-size: 13px;
  }

  .mobile-layout .el-form-item__label {
    width: 65px !important;
  }

  .submit-btn {
    height: 40px !important;
    font-size: 14px !important;
  }
}

/* 横屏模式优化 */
@media screen and (max-height: 500px) and (orientation: landscape) {
  .box-card {
    margin-bottom: 10px;
  }

  .box-card .el-card__header {
    padding: 8px 12px;
  }

  .box-card .el-card__body {
    padding: 10px;
  }

  .mobile-layout .el-form-item {
    margin-bottom: 12px;
  }

  .mobile-layout .el-form-item__label {
    line-height: 28px;
    font-size: 13px;
  }

  .mobile-row {
    margin-bottom: 12px;
    gap: 10px;
  }

  .mobile-item .el-input-number .el-input__inner {
    height: 30px;
    line-height: 30px;
    padding: 5px 32px 5px 8px;
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__increase,
  .mobile-item .el-input-number.is-controls-right .el-input-number__decrease {
    width: 26px;
    line-height: 14px;
  }

  .mobile-layout .el-input__inner {
    height: 30px;
    line-height: 30px;
  }

  .submit-btn {
    height: 38px !important;
    margin-top: 4px;
  }
}

/* 平板横屏适配 */
@media screen and (min-width: 768px) and (max-width: 1024px) and (orientation: landscape) {
  .box-card {
    margin-bottom: 15px;
  }

  .desktop-layout .el-form-item__label {
    width: 80px !important;
  }
}

/* 触控优化 - 针对触摸屏设备 */
@media (hover: none) and (pointer: coarse) {
  /* 增加按钮和输入框的可点击区域 */
  .mobile-layout .el-input__inner,
  .mobile-item .el-input-number .el-input__inner {
    padding-top: 6px;
    padding-bottom: 6px;
    min-height: 44px; /* iOS推荐的触控目标最小尺寸 */
  }

  .mobile-item .el-input-number.is-controls-right .el-input-number__increase,
  .mobile-item .el-input-number.is-controls-right .el-input-number__decrease {
    min-width: 32px;
    min-height: 22px;
    line-height: 11px;
  }

  .switch-wrapper .el-switch {
    transform: scale(1.15);
  }

  .switch-wrapper .el-switch__label {
    margin-left: 10px;
    font-size: 14px;
  }

  .submit-btn {
    min-height: 48px;
    font-size: 16px !important;
  }
}

/* 确保输入框不超出容器 */
.exercise-form .el-input__inner,
.exercise-form .el-input-number,
.exercise-form .el-date-editor {
  max-width: 100%;
}

/* 焦点状态优化 */
.mobile-layout .el-input:focus .el-input__inner,
.mobile-layout .el-input.is-focus .el-input__inner,
.mobile-layout .el-input-number.is-focus .el-input-number__decrease,
.mobile-layout .el-input-number.is-focus .el-input-number__increase {
  border-color: #409EFF;
  outline: none;
}

/* 错误状态优化 */
.mobile-layout .el-form-item.is-error .el-input__inner,
.mobile-layout .el-form-item.is-error .el-input-number__inner {
  border-color: #F56C6C;
  animation: shake 0.3s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}
</style>