<template>
  <div class="daily-summary">
    <el-row :gutter="20">
      <el-col :xs="12" :sm="12" :md="6">
        <el-card class="summary-card">
          <div class="summary-title">摄入热量</div>
          <div class="summary-value">{{ totalIntake }} 千卡</div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card class="summary-card">
          <div class="summary-title">消耗热量</div>
          <div class="summary-value">{{ totalBurned }} 千卡</div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card class="summary-card">
          <div class="summary-title">净热量</div>
          <div class="summary-value" :class="{ positive: netCalories > 0, negative: netCalories < 0 }">
            {{ netCalories }} 千卡
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card class="summary-card">
          <div class="summary-title">今日餐次分布</div>
          <div class="summary-value">{{ mealDistribution }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-divider></el-divider>

    <el-form inline>
      <el-form-item label="选择日期">
        <el-date-picker
          v-model="localSelectedDate"
          type="date"
          format="yyyy-MM-dd"
          value-format="yyyy-MM-dd"
          placeholder="选择日期"
          style="width: 100%;">
        </el-date-picker>
      </el-form-item>
    </el-form>

    <!-- 桌面端食物表格 -->
    <el-table :data="dailyFoods" style="width: 100%" stripe class="desktop-table">
      <el-table-column prop="name" label="食物名称" width="180"></el-table-column>
      <el-table-column prop="weight" label="重量(g)" width="100"></el-table-column>
      <el-table-column prop="calories" label="热量(千卡)" width="120"></el-table-column>
      <el-table-column prop="mealType" label="餐别" width="100"></el-table-column>
    </el-table>

    <!-- 移动端食物卡片列表 -->
    <div class="mobile-food-list">
      <el-card v-for="food in dailyFoods" :key="food.id" class="food-card" shadow="hover">
        <div class="card-header">
          <span class="food-name">{{ food.name }}</span>
          <el-tag type="info" size="small">{{ food.mealType }}</el-tag>
        </div>
        <div class="card-content">
          <div class="info-item">
            <span class="label">重量:</span>
            <span class="value">{{ food.weight }}g</span>
          </div>
          <div class="info-item">
            <span class="label">热量:</span>
            <span class="value">{{ food.calories }}千卡</span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 桌面端运动表格 -->
    <el-table :data="dailyExercises" style="width: 100%; margin-top: 20px;" stripe class="desktop-table">
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
    </el-table>

    <!-- 移动端运动卡片列表 -->
    <div class="mobile-exercise-list">
      <el-card v-for="exercise in dailyExercises" :key="exercise.id" class="exercise-card" shadow="hover">
        <div class="card-header">
          <span class="exercise-name">{{ exercise.name }}</span>
          <el-tag :type="exercise.completed ? 'success' : 'danger'" size="small">
            {{ exercise.completed ? '已完成' : '未完成' }}
          </el-tag>
        </div>
        <div class="card-content">
          <div class="info-item">
            <span class="label">组数:</span>
            <span class="value">{{ exercise.sets }}</span>
          </div>
          <div class="info-item">
            <span class="label">消耗:</span>
            <span class="value">{{ exercise.caloriesBurned }}千卡</span>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DailySummary',
  props: {
    selectedDate: {
      type: String,
      default: () => new Date().toISOString().slice(0, 10)
    }
  },
  data() {
    return {
      localSelectedDate: this.selectedDate
    }
  },
  computed: {
    // 当日食物摄入
    dailyFoods() {
      return this.$store.getters.foodsByDate(this.localSelectedDate);
    },
    // 当日运动记录
    dailyExercises() {
      return this.$store.getters.exercisesByDate(this.localSelectedDate);
    },
    // 总摄入热量
    totalIntake() {
      return this.$store.getters.totalIntakeByDate(this.localSelectedDate);
    },
    // 总消耗热量
    totalBurned() {
      return this.$store.getters.totalBurnedByDate(this.localSelectedDate);
    },
    // 净热量
    netCalories() {
      return this.totalIntake - this.totalBurned;
    },
    // 餐次分布
    mealDistribution() {
      const meals = {};
      this.dailyFoods.forEach(food => {
        meals[food.mealType] = (meals[food.mealType] || 0) + 1;
      });
      
      return Object.entries(meals).map(([meal, count]) => `${meal}(${count})`).join(', ') || '无';
    }
  },
  watch: {
    selectedDate(newVal) {
      this.localSelectedDate = newVal;
    },
    localSelectedDate(newVal) {
      this.$emit('update:selectedDate', newVal);
    }
  }
}
</script>

<style scoped>
.daily-summary {
  margin-top: 20px;
}

/* 汇总卡片美化 */
.summary-card {
  text-align: center;
  margin-bottom: 10px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
}

.summary-card:hover {
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.summary-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
  font-weight: 500;
  letter-spacing: 0.3px;
}

.summary-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  word-break: break-all;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.positive {
  background: linear-gradient(135deg, #f56c6c 0%, #ff7e7e 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.negative {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* 桌面端表格 - 默认显示 */
.desktop-table {
  display: table;
}

/* 移动端卡片列表 - 默认隐藏 */
.mobile-food-list,
.mobile-exercise-list {
  display: none;
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .daily-summary {
    margin-top: 15px;
  }

  .summary-card {
    margin-bottom: 12px;
    border-radius: 8px;
  }

  .summary-card .el-card__body {
    padding: 12px;
  }

  .summary-title {
    font-size: 12px;
    margin-bottom: 8px;
  }

  .summary-value {
    font-size: 20px;
  }

  /* 隐藏桌面表格 */
  .desktop-table {
    display: none;
  }

  /* 显示移动端卡片列表 */
  .mobile-food-list,
  .mobile-exercise-list {
    display: block;
    margin-top: 15px;
  }

  .food-card,
  .exercise-card {
    margin-bottom: 12px;
    border-radius: 8px;
  }

  .food-card .el-card__body,
  .exercise-card .el-card__body {
    padding: 12px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
  }

  .food-name,
  .exercise-name {
    font-weight: bold;
    font-size: 16px;
    color: #333;
  }

  .card-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
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

  /* 表单适配 */
  .el-form-item {
    width: 100%;
  }

  .el-form-item__content {
    width: 100%;
  }

  .el-date-editor {
    width: 100%;
  }

  .el-date-editor .el-input__inner {
    font-size: 16px;
  }
}

@media screen and (max-width: 480px) {
  .daily-summary {
    margin-top: 10px;
  }

  .summary-card {
    margin-bottom: 10px;
  }

  .summary-card .el-card__body {
    padding: 10px;
  }

  .summary-title {
    font-size: 11px;
    margin-bottom: 6px;
  }

  .summary-value {
    font-size: 18px;
  }

  .food-card,
  .exercise-card {
    margin-bottom: 10px;
  }

  .food-card .el-card__body,
  .exercise-card .el-card__body {
    padding: 10px;
  }

  .card-header {
    margin-bottom: 8px;
    padding-bottom: 8px;
  }

  .food-name,
  .exercise-name {
    font-size: 15px;
  }

  .info-item .label,
  .info-item .value {
    font-size: 13px;
  }
}

/* 超小屏手机适配 */
@media screen and (max-width: 360px) {
  .summary-card {
    margin-bottom: 8px;
  }

  .summary-card .el-card__body {
    padding: 8px;
  }

  .summary-title {
    font-size: 10px;
  }

  .summary-value {
    font-size: 16px;
  }

  .food-card .el-card__body,
  .exercise-card .el-card__body {
    padding: 8px;
  }

  .food-name,
  .exercise-name {
    font-size: 14px;
  }
}

/* 横屏模式优化 */
@media screen and (max-height: 500px) and (orientation: landscape) {
  .summary-card .el-card__body {
    padding: 8px;
  }

  .summary-title {
    margin-bottom: 4px;
  }

  .food-card,
  .exercise-card {
    margin-bottom: 8px;
  }

  .card-header {
    margin-bottom: 6px;
    padding-bottom: 6px;
  }

  .card-content {
    gap: 6px;
  }
}

/* 触控优化 */
@media (hover: none) and (pointer: coarse) {
  .food-card:active,
  .exercise-card:active {
    transform: scale(0.99);
    transition: transform 0.1s;
  }

  .food-card:hover,
  .exercise-card:hover {
    cursor: pointer;
  }
}
</style>