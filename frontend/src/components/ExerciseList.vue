<template>
  <div class="exercise-list">
    <!-- 桌面端表格 -->
    <el-table :data="filteredExercises" style="width: 100%" stripe class="desktop-table">
      <el-table-column prop="name" label="运动项目" width="180"></el-table-column>
      <el-table-column prop="sets" label="组数" width="100"></el-table-column>
      <el-table-column prop="completed" label="是否完成" width="120">
        <template slot-scope="scope">
          <el-tag :type="scope.row.completed ? 'success' : 'danger'">
            {{ scope.row.completed ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="caloriesBurned" label="消耗热量" width="120"></el-table-column>
      <el-table-column prop="date" label="日期" width="120"></el-table-column>
      <el-table-column label="操作" width="200">
        <template slot-scope="scope">
          <el-button size="mini" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 移动端卡片列表 -->
    <div class="mobile-card-list">
      <el-card v-for="item in filteredExercises" :key="item.id" class="exercise-card" shadow="hover">
        <div class="card-header">
          <span class="exercise-name">{{ item.name }}</span>
          <el-tag :type="item.completed ? 'success' : 'danger'" size="small">
            {{ item.completed ? '已完成' : '未完成' }}
          </el-tag>
        </div>
        <div class="card-content">
          <div class="info-item">
            <span class="label">组数:</span>
            <span class="value">{{ item.sets }}</span>
          </div>
          <div class="info-item">
            <span class="label">消耗:</span>
            <span class="value">{{ item.caloriesBurned }}千卡</span>
          </div>
          <div class="info-item">
            <span class="label">日期:</span>
            <span class="value">{{ item.date }}</span>
          </div>
        </div>
        <div class="card-actions">
          <el-button type="primary" size="small" @click="handleEdit(item)">编辑</el-button>
          <el-button type="danger" size="small" @click="handleDelete(item)">删除</el-button>
        </div>
      </el-card>
    </div>

    <!-- 编辑弹窗 - 桌面端 -->
    <el-dialog title="编辑运动记录" :visible.sync="dialogVisible" width="50%" :modal-append-to-body="true" class="desktop-dialog">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="运动项目">
          <el-input v-model="editForm.name"></el-input>
        </el-form-item>
        <el-form-item label="组数">
          <el-input-number v-model="editForm.sets" :min="1" :step="1"></el-input-number>
        </el-form-item>
        <el-form-item label="是否完成">
          <el-switch
            v-model="editForm.completed"
            active-text="是"
            inactive-text="否">
          </el-switch>
        </el-form-item>
        <el-form-item label="消耗热量">
          <el-input-number v-model="editForm.caloriesBurned" :min="0" :step="50"></el-input-number>
        </el-form-item>
        <el-form-item label="日期">
          <el-date-picker
            v-model="editForm.date"
            type="date"
            format="yyyy-MM-dd"
            value-format="yyyy-MM-dd">
          </el-date-picker>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmEdit">确定</el-button>
      </span>
    </el-dialog>

    <!-- 编辑弹窗 - 移动端 -->
    <el-dialog title="编辑运动记录" :visible.sync="dialogVisible" width="90%" :modal-append-to-body="true" class="mobile-dialog" :close-on-click-modal="false" :lock-scroll="true">
      <el-form :model="editForm" label-width="80px" size="small">
        <el-form-item label="运动项目">
          <el-input v-model="editForm.name" placeholder="请输入运动项目"></el-input>
        </el-form-item>

        <div class="edit-dialog-row">
          <el-form-item label="组数" style="flex: 1;">
            <el-input-number v-model="editForm.sets" :min="1" :step="1" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </el-form-item>
          <el-form-item label="消耗热量" style="flex: 1;">
            <el-input-number v-model="editForm.caloriesBurned" :min="0" :step="50" placeholder="千卡" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </el-form-item>
        </div>

        <el-form-item label="完成状态">
          <div class="edit-switch-wrapper">
            <el-switch
              v-model="editForm.completed"
              active-text="已完成"
              inactive-text="未完成">
            </el-switch>
          </div>
        </el-form-item>

        <el-form-item label="日期">
          <el-date-picker
            v-model="editForm.date"
            type="date"
            format="yyyy-MM-dd"
            value-format="yyyy-MM-dd"
            style="width: 100%;">
          </el-date-picker>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer" style="display: flex; gap: 10px;">
        <el-button @click="dialogVisible = false" style="flex: 1;">取消</el-button>
        <el-button type="primary" @click="confirmEdit" style="flex: 1;">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'ExerciseList',
  data() {
    return {
      dialogVisible: false,
      editForm: {},
      currentEditId: null
    }
  },
  computed: {
    filteredExercises() {
      // 按日期倒序排列
      return [...this.$store.state.exercises].sort((a, b) => new Date(b.date) - new Date(a.date));
    }
  },
  methods: {
    handleDelete(row) {
      this.$confirm(`确定删除 "${row.name}" 的记录吗？`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$store.dispatch('deleteExercise', row.id);
        this.$message.success('删除成功');
      });
    },
    handleEdit(row) {
      this.editForm = { ...row };
      this.currentEditId = row.id;
      this.dialogVisible = true;
    },
    confirmEdit() {
      this.$store.dispatch('updateExercise', { ...this.editForm, id: this.currentEditId });
      this.dialogVisible = false;
      this.$message.success('更新成功');
    }
  }
}
</script>

<style scoped>
.exercise-list {
  margin-top: 20px;
}

/* 桌面端表格 - 默认显示 */
.desktop-table {
  display: table;
}

/* 移动端卡片列表 - 默认隐藏 */
.mobile-card-list {
  display: none;
}

/* 卡片美化 */
.exercise-card {
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.exercise-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  transform: translateY(-4px);
}

.exercise-card:active {
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

.exercise-name {
  font-weight: bold;
  font-size: 17px;
  color: #764ba2;
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
  color: #764ba2;
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
  box-shadow: 0 4px 12px rgba(118, 75, 162, 0.3);
}

.card-actions .el-button--danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(235, 51, 73, 0.3);
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  /* 隐藏桌面表格 */
  .desktop-table {
    display: none;
  }

  /* 隐藏桌面对话框 */
  .desktop-dialog {
    display: none;
  }

  /* 显示移动端卡片列表 */
  .mobile-card-list {
    display: block;
  }

  /* 显示移动端对话框 */
  .mobile-dialog {
    display: block;
  }

  .exercise-card {
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

  .exercise-name {
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

  /* 对话框适配 */
  .el-dialog {
    width: 90% !important;
    margin-top: 5vh !important;
    max-height: 85vh;
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
    max-height: 60vh;
    overflow-y: auto;
    padding: 20px;
    -webkit-overflow-scrolling: touch;
  }

  .el-dialog__footer {
    padding: 15px 20px;
    border-top: 1px solid #eee;
  }

  .el-form-item__label {
    width: 80px !important;
    font-size: 14px;
    line-height: 36px;
  }

  .el-dialog .el-input__inner {
    font-size: 16px;
    height: 36px;
    line-height: 36px;
  }

  /* 编辑对话框横向排列 */
  .edit-dialog-row {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
  }

  .edit-dialog-row .el-form-item {
    margin-bottom: 0;
  }

  /* 开关组件包装 */
  .edit-switch-wrapper {
    width: 100%;
    display: flex;
    align-items: center;
    padding: 4px 0;
  }

  .edit-switch-wrapper .el-switch {
    transform: scale(1.1);
    transform-origin: left center;
  }

  .edit-switch-wrapper .el-switch__label {
    font-size: 13px;
    margin-left: 8px;
  }

  /* 输入数字控件优化 */
  .edit-dialog-row .el-input-number {
    flex: 1;
  }

  .edit-dialog-row .el-input-number .el-input__inner {
    font-size: 16px; /* 防止iOS缩放 */
    padding: 5px 36px 5px 10px;
    height: 36px;
    line-height: 36px;
  }

  .edit-dialog-row .el-input-number.is-controls-right .el-input-number__increase,
  .edit-dialog-row .el-input-number.is-controls-right .el-input-number__decrease {
    width: 28px;
    line-height: 17px;
    background-color: #f5f7fa;
  }

  /* 日期选择器优化 */
  .el-dialog .el-date-editor .el-input__inner {
    padding-left: 30px;
  }

  /* 对话框按钮优化 */
  .dialog-footer .el-button {
    height: 40px;
    font-size: 15px;
    border-radius: 8px;
  }

  .dialog-footer .el-button:active {
    transform: scale(0.98);
  }
}

@media screen and (max-width: 480px) {
  .exercise-card {
    margin-bottom: 12px;
  }

  .exercise-name {
    font-size: 15px;
  }

  .info-item .label,
  .info-item .value {
    font-size: 13px;
  }

  .card-actions .el-button {
    font-size: 13px;
    padding: 8px 12px;
    height: 36px;
  }

  /* 对话框适配 */
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

  .el-form-item__label {
    width: 70px !important;
    font-size: 13px;
    line-height: 34px;
  }

  .el-dialog .el-input__inner {
    height: 34px;
    line-height: 34px;
  }

  .edit-dialog-row {
    gap: 8px;
  }

  .edit-dialog-row .el-input-number .el-input__inner {
    padding: 5px 34px 5px 8px;
    font-size: 15px;
    height: 34px;
  }

  .edit-switch-wrapper .el-switch__label {
    font-size: 12px;
    margin-left: 6px;
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
    font-size: 15px;
  }

  .el-dialog__body {
    padding: 12px;
  }

  .el-dialog__footer {
    padding: 10px 12px;
  }

  .edit-dialog-row {
    flex-direction: column;
    gap: 12px;
  }

  .edit-dialog-row .el-form-item {
    width: 100%;
  }

  .edit-dialog-row .el-input-number .el-input__inner {
    padding: 5px 32px 5px 10px;
    height: 34px;
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

  .edit-dialog-row {
    gap: 10px;
    margin-bottom: 12px;
  }
}

/* 触控优化 - 针对触摸屏设备 */
@media (hover: none) and (pointer: coarse) {
  /* 增加卡片按钮的可点击区域 */
  .card-actions .el-button {
    min-height: 44px;
    padding: 10px 15px;
  }

  /* 对话框内输入框优化 */
  .el-dialog .el-input__inner,
  .edit-dialog-row .el-input-number .el-input__inner {
    padding-top: 6px;
    padding-bottom: 6px;
    min-height: 44px;
  }

  .edit-dialog-row .el-input-number.is-controls-right .el-input-number__increase,
  .edit-dialog-row .el-input-number.is-controls-right .el-input-number__decrease {
    min-width: 32px;
    min-height: 22px;
    line-height: 11px;
  }

  /* 开关组件优化 */
  .edit-switch-wrapper .el-switch {
    transform: scale(1.15);
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
    display: none;
  }
}
</style>