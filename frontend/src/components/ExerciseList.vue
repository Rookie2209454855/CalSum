<template>
  <div class="exercise-list">
    <el-table :data="filteredExercises" style="width: 100%" stripe>
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
    
    <!-- 编辑弹窗 -->
    <el-dialog title="编辑运动记录" :visible.sync="dialogVisible" width="50%">
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
</style>