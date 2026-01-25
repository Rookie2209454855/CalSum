<template>
  <div class="food-list">
    <el-table :data="filteredFoods" style="width: 100%" stripe>
      <el-table-column prop="name" label="食物名称" width="180"></el-table-column>
      <el-table-column prop="weight" label="重量(g)" width="100"></el-table-column>
      <el-table-column prop="calories" label="热量(千卡)" width="120"></el-table-column>
      <el-table-column prop="date" label="日期" width="120"></el-table-column>
      <el-table-column prop="mealType" label="餐别" width="100"></el-table-column>
      <el-table-column label="操作" width="200">
        <template slot-scope="scope">
          <el-button size="mini" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 编辑弹窗 -->
    <el-dialog title="编辑食物记录" :visible.sync="dialogVisible" width="50%">
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="食物名称">
          <el-input v-model="editForm.name"></el-input>
        </el-form-item>
        <el-form-item label="重量(g)">
          <el-input-number v-model="editForm.weight" :min="1" :step="10"></el-input-number>
        </el-form-item>
        <el-form-item label="热量(千卡)">
          <el-input-number v-model="editForm.calories" :min="1" :step="50"></el-input-number>
        </el-form-item>
        <el-form-item label="日期">
          <el-date-picker
            v-model="editForm.date"
            type="date"
            format="yyyy-MM-dd"
            value-format="yyyy-MM-dd">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="餐别">
          <el-select v-model="editForm.mealType">
            <el-option label="早餐" value="早餐"></el-option>
            <el-option label="午餐" value="午餐"></el-option>
            <el-option label="晚餐" value="晚餐"></el-option>
            <el-option label="加餐" value="加餐"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmEdit">确定</el-button>
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
</style>