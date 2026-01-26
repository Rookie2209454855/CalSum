<template>
  <div class="input-view">
    <el-tabs v-model="activeTab" type="card" stretch>
      <el-tab-pane label="食物摄入" name="food">
        <FoodInput @add-food="addFood" />
      </el-tab-pane>
      <el-tab-pane label="运动记录" name="exercise">
        <ExerciseInput @add-exercise="addExercise" />
      </el-tab-pane>
      <el-tab-pane label="每日汇总" name="summary">
        <DailySummary :selectedDate.sync="selectedDate" />
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
  padding: 20px;
}

/* 标签页美化 */
.el-tabs--card > .el-tabs__header {
  background: linear-gradient(135deg, #f5f7fa 0%, #ffffff 100%);
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  padding: 4px;
}

.el-tabs--card > .el-tabs__nav-scroll::after {
  display: none;
}

.el-tabs--card > .el-tabs__item {
  border: none;
  background: transparent;
  color: #606266;
  font-weight: 500;
  font-size: 15px;
  padding: 0 20px;
  height: 48px;
  line-height: 48px;
  transition: all 0.3s ease;
  border-radius: 8px;
  margin-right: 4px;
}

.el-tabs--card > .el-tabs__item:hover {
  background: rgba(102, 126, 234, 0.08);
  color: #667eea;
  transform: translateY(-2px);
}

.el-tabs--card > .el-tabs__item.is-active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.el-tabs--card > .el-tabs__content {
  padding: 20px;
  margin-top: 20px;
  border-radius: 12px;
  background: #ffffff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

@media screen and (max-width: 768px) {
  .input-view {
    max-width: 100%;
    padding: 10px;
  }

  .el-tabs__nav-wrap {
    padding: 0 10px;
  }

  .el-tabs--card > .el-tabs__item {
    font-size: 13px;
    padding: 0 12px;
    height: 44px;
    line-height: 44px;
  }
}

@media screen and (max-width: 480px) {
  .el-tabs--card > .el-tabs__item {
    font-size: 12px;
    padding: 0 8px;
    height: 40px;
    line-height: 40px;
  }
}
</style>