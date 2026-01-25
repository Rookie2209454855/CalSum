<template>
  <el-card class="box-card" header="添加食物摄入">
    <el-form :model="form" label-width="100px" @submit.native.prevent>
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="食物名称">
            <el-input
              v-model="form.name"
              placeholder="请输入食物名称"
              style="width: 100%;">
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="重量(g)">
            <el-input-number 
              v-model="form.weight" 
              :min="1" 
              :step="10" 
              placeholder="克"
              style="width: 100%;">
            </el-input-number>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="热量(千卡)">
            <el-input-number 
              v-model="form.calories" 
              :min="1" 
              :step="50" 
              placeholder="千卡"
              style="width: 100%;">
            </el-input-number>
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
          <el-form-item label="餐别">
            <el-select v-model="form.mealType" placeholder="请选择餐别">
              <el-option label="早餐" value="早餐"></el-option>
              <el-option label="午餐" value="午餐"></el-option>
              <el-option label="晚餐" value="晚餐"></el-option>
              <el-option label="加餐" value="加餐"></el-option>
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item>
            <el-button type="primary" @click="addFood">添加</el-button>
          </el-form-item>
        </el-col>
      </el-row>
    </el-form>
  </el-card>
</template>

<script>
export default {
  name: 'FoodInput',
  data() {
    return {
      form: {
        name: '',
        weight: null,
        calories: null,
        date: new Date().toISOString().slice(0, 10),
        mealType: ''
      }
    }
  },
  methods: {
    addFood() {
      if (!this.form.name || !this.form.weight || !this.form.calories || !this.form.date || !this.form.mealType) {
        this.$message.error('请填写完整信息');
        return;
      }

      this.$store.dispatch('addFood', { ...this.form, id: Date.now() });
      this.$message.success('食物记录添加成功');
      
      // 重置表单
      this.form = {
        name: '',
        weight: null,
        calories: null,
        date: new Date().toISOString().slice(0, 10),
        mealType: ''
      };
    }
  }
}
</script>

<style scoped>
.el-col {
  position: relative;
}
</style>