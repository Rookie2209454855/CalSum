<template>
  <el-card class="box-card" header="添加运动记录" style="margin-bottom: 20px;">
    <el-form :model="form" label-width="100px" @submit.native.prevent>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-form-item label="运动项目">
            <el-input v-model="form.name" placeholder="请输入运动项目"></el-input>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="组数">
            <el-input-number v-model="form.sets" :min="1" :step="1" placeholder="组"></el-input-number>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="是否完成">
            <el-switch
              v-model="form.completed"
              active-text="是"
              inactive-text="否">
            </el-switch>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="消耗热量">
            <el-input-number v-model="form.caloriesBurned" :min="0" :step="50" placeholder="千卡"></el-input-number>
          </el-form-item>
        </el-col>
      </el-row>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="日期">
            <el-date-picker
              v-model="form.date"
              type="date"
              placeholder="选择日期"
              format="yyyy-MM-dd"
              value-format="yyyy-MM-dd">
            </el-date-picker>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item>
            <el-button type="primary" @click="addExercise">添加</el-button>
          </el-form-item>
        </el-col>
      </el-row>
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
}
</style>