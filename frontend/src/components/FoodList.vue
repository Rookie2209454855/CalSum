<template>
  <div class="food-list">
    <!-- 桌面端表格 -->
    <el-table :data="filteredFoods" style="width: 100%" stripe class="desktop-table">
      <el-table-column prop="name" label="食物名称" width="180"></el-table-column>
      <el-table-column prop="weight" label="重量(g)" width="100"></el-table-column>
      <el-table-column prop="calories" label="热量(千卡)" width="120"></el-table-column>
      <el-table-column prop="mealType" label="餐别" width="100"></el-table-column>
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
      <el-card v-for="item in filteredFoods" :key="item.id" class="food-card" shadow="hover">
        <div class="card-header">
          <span class="food-name">{{ item.name }}</span>
          <el-tag type="info" size="small">{{ item.mealType }}</el-tag>
        </div>
        <div class="card-content">
          <div class="info-item">
            <span class="label">重量:</span>
            <span class="value">{{ item.weight }}g</span>
          </div>
          <div class="info-item">
            <span class="label">热量:</span>
            <span class="value">{{ item.calories }}千卡</span>
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
    <el-dialog title="编辑食物记录" :visible.sync="dialogVisible" width="50%" :modal-append-to-body="false" class="desktop-dialog">
      <el-form :model="editForm" label-width="120px">
        <el-form-item label="食物名称">
          <el-input v-model="editForm.name"></el-input>
        </el-form-item>
        <el-form-item label="重量(g)">
          <el-input-number v-model="editForm.weight" :min="1" :step="10"></el-input-number>
        </el-form-item>
        <el-form-item label="热量(千卡)">
          <el-input-number v-model="editForm.calories" :min="1" :step="50"></el-input-number>
        </el-form-item>
        <el-form-item label="餐别">
          <el-select v-model="editForm.mealType" placeholder="请选择餐别" style="width: 100%;">
            <el-option label="早餐" value="早餐"></el-option>
            <el-option label="午餐" value="午餐"></el-option>
            <el-option label="晚餐" value="晚餐"></el-option>
            <el-option label="加餐" value="加餐"></el-option>
          </el-select>
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
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmEdit">确定</el-button>
      </span>
    </el-dialog>

    <!-- 编辑弹窗 - 移动端 -->
    <el-dialog title="编辑食物记录" :visible.sync="dialogVisible" width="90%" :modal-append-to-body="false" class="mobile-dialog" :close-on-click-modal="false" :lock-scroll="true">
      <el-form :model="editForm" label-width="80px" size="small">
        <el-form-item label="食物名称">
          <el-input v-model="editForm.name" placeholder="请输入食物名称"></el-input>
        </el-form-item>

        <div class="edit-dialog-row">
          <el-form-item label="重量(g)" style="flex: 1;">
            <el-input-number v-model="editForm.weight" :min="1" :step="10" placeholder="g" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </el-form-item>
          <el-form-item label="热量" style="flex: 1;">
            <el-input-number v-model="editForm.calories" :min="1" :step="50" placeholder="千卡" :controls-position="'right'" style="width: 100%;"></el-input-number>
          </el-form-item>
        </div>

        <el-form-item label="餐别">
          <el-select v-model="editForm.mealType" placeholder="请选择餐别" style="width: 100%;">
            <el-option label="早餐" value="早餐"></el-option>
            <el-option label="午餐" value="午餐"></el-option>
            <el-option label="晚餐" value="晚餐"></el-option>
            <el-option label="加餐" value="加餐"></el-option>
          </el-select>
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
  name: 'FoodList',
  data() {
    return {
      dialogVisible: false,
      editForm: {},
      currentEditId: null
    }
  },
  computed: {
    filteredFoods() {
      // 按日期倒序排列
      return [...this.$store.state.foods].sort((a, b) => new Date(b.date) - new Date(a.date));
    }
  },
  methods: {
    handleDelete(row) {
      this.$confirm(`确定删除 "${row.name}" 的记录吗？`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$store.dispatch('deleteFood', row.id);
        this.$message.success('删除成功');
      });
    },
    handleEdit(row) {
      this.editForm = { ...row };
      this.currentEditId = row.id;
      this.dialogVisible = true;
    },
    confirmEdit() {
      this.$store.dispatch('updateFood', { ...this.editForm, id: this.currentEditId });
      this.dialogVisible = false;
      this.$message.success('更新成功');
    }
  }
}
</script>

<style scoped>
.food-list {
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
.food-card {
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.food-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  transform: translateY(-4px);
}

.food-card:active {
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

.food-name {
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

  .food-card {
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

  .food-name {
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

  /* 选择器优化 */
  .el-dialog .el-select .el-input__inner {
    padding-right: 35px;
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
  .food-card {
    margin-bottom: 12px;
  }

  .food-name {
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
