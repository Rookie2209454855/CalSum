<template>
  <div class="manage-view">
    <el-tabs v-model="activeTab" type="card">
      <el-tab-pane label="食物记录管理" name="food">
        <FoodList />
      </el-tab-pane>
      <el-tab-pane label="运动记录管理" name="exercise">
        <ExerciseList />
      </el-tab-pane>
      <el-tab-pane label="数据导出" name="export">
        <ExportData />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import FoodList from '../components/FoodList.vue'
import ExerciseList from '../components/ExerciseList.vue'
import ExportData from '../components/ExportData.vue'

export default {
  name: 'ManageView',
  components: {
    FoodList,
    ExerciseList,
    ExportData
  },
  data() {
    return {
      activeTab: 'food'
    }
  }
}
</script>

<style scoped>
.manage-view {
  max-width: 1200px;
  margin: 0 auto;
}
</style>