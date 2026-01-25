<template>
  <div class="input-view">
    <el-tabs v-model="activeTab" type="card">
      <el-tab-pane label="食物摄入" name="food">
        <FoodInput @add-food="addFood" />
      </el-tab-pane>
      <el-tab-pane label="运动记录" name="exercise">
        <ExerciseInput @add-exercise="addExercise" />
      </el-tab-pane>
      <el-tab-pane label="每日汇总" name="summary">
        <DailySummary :selectedDate="selectedDate" />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import FoodInput from '../components/FoodInput.vue'
import ExerciseInput from '../components/ExerciseInput.vue'
import DailySummary from '../components/DailySummary.vue'

export default {
  name: 'InputView',
  components: {
    FoodInput,
    ExerciseInput,
    DailySummary
  },
  data() {
    return {
      activeTab: 'food',
      selectedDate: new Date().toISOString().slice(0, 10)
    }
  },
  methods: {
    addFood(food) {
      this.$store.dispatch('addFood', {...food, id: Date.now()})
      this.$message.success('食物记录添加成功')
    },
    addExercise(exercise) {
      this.$store.dispatch('addExercise', {...exercise, id: Date.now()})
      this.$message.success('运动记录添加成功')
    }
  }
}
</script>

<style scoped>
.input-view {
  max-width: 1200px;
  margin: 0 auto;
}
</style>