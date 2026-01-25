<template>
  <div class="daily-summary">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card class="summary-card">
          <div class="summary-title">摄入热量</div>
          <div class="summary-value">{{ totalIntake }} 千卡</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="summary-card">
          <div class="summary-title">消耗热量</div>
          <div class="summary-value">{{ totalBurned }} 千卡</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="summary-card">
          <div class="summary-title">净热量</div>
          <div class="summary-value" :class="{ positive: netCalories > 0, negative: netCalories < 0 }">
            {{ netCalories }} 千卡
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
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
          v-model="selectedDate"
          type="date"
          format="yyyy-MM-dd"
          value-format="yyyy-MM-dd"
          placeholder="选择日期">
        </el-date-picker>
      </el-form-item>
    </el-form>
    
    <el-table :data="dailyFoods" style="width: 100%" stripe>
      <el-table-column prop="name" label="食物名称" width="180"></el-table-column>
      <el-table-column prop="weight" label="重量(g)" width="100"></el-table-column>
      <el-table-column prop="calories" label="热量(千卡)" width="120"></el-table-column>
      <el-table-column prop="mealType" label="餐别" width="100"></el-table-column>
    </el-table>
    
    <el-table :data="dailyExercises" style="width: 100%; margin-top: 20px;" stripe>
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

.summary-card {
  text-align: center;
}

.summary-title {
  font-size: 14px;
  color: #606266;
  margin-bottom: 10px;
}

.summary-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.positive {
  color: #f56c6c;
}

.negative {
  color: #67c23a;
}
</style>