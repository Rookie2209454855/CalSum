<template>
  <div class="export-data">
    <el-form :inline="true">
      <el-form-item label="导出日期范围">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          format="yyyy-MM-dd"
          value-format="yyyy-MM-dd">
        </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="exportAsMarkdown">导出 Markdown</el-button>
        <el-button type="success" @click="exportAsExcel">导出 Excel</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
import * as XLSX from 'xlsx';

export default {
  name: 'ExportData',
  data() {
    return {
      dateRange: []
    }
  },
  computed: {
    allFoods() {
      return this.$store.state.foods;
    },
    allExercises() {
      return this.$store.state.exercises;
    }
  },
  methods: {
    // 过滤指定日期范围内的数据
    getFilteredData() {
      let filteredFoods = this.allFoods;
      let filteredExercises = this.allExercises;

      if (this.dateRange && this.dateRange.length === 2) {
        const startDate = new Date(this.dateRange[0]);
        const endDate = new Date(this.dateRange[1]);

        filteredFoods = this.allFoods.filter(item => {
          const itemDate = new Date(item.date);
          return itemDate >= startDate && itemDate <= endDate;
        });

        filteredExercises = this.allExercises.filter(item => {
          const itemDate = new Date(item.date);
          return itemDate >= startDate && itemDate <= endDate;
        });
      }

      return { foods: filteredFoods, exercises: filteredExercises };
    },

    exportAsMarkdown() {
      const { foods, exercises } = this.getFilteredData();
      let markdown = "# 食物摄入与运动记录\n\n";

      // 添加食物记录部分
      if (foods.length > 0) {
        markdown += "## 食物摄入记录\n\n";
        markdown += "| 食物名称 | 重量(g) | 热量(千卡) | 日期 | 餐别 |\n";
        markdown += "| --- | --- | --- | --- | --- |\n";

        foods.forEach(food => {
          markdown += `| ${food.name} | ${food.weight} | ${food.calories} | ${food.date} | ${food.mealType} |\n`;
        });

        markdown += "\n";
      }

      // 添加运动记录部分
      if (exercises.length > 0) {
        markdown += "## 运动记录\n\n";
        markdown += "| 运动项目 | 组数 | 是否完成 | 消耗热量 | 日期 |\n";
        markdown += "| --- | --- | --- | --- | --- |\n";

        exercises.forEach(exercise => {
          const completedText = exercise.completed ? '是' : '否';
          markdown += `| ${exercise.name} | ${exercise.sets} | ${completedText} | ${exercise.caloriesBurned} | ${exercise.date} |\n`;
        });

        markdown += "\n";
      }

      // 添加统计摘要
      if (foods.length > 0 || exercises.length > 0) {
        markdown += "## 统计摘要\n\n";
        
        const totalIntake = foods.reduce((sum, food) => sum + food.calories, 0);
        const totalBurned = exercises.reduce((sum, exercise) => sum + (exercise.caloriesBurned || 0), 0);
        const netCalories = totalIntake - totalBurned;
        
        markdown += `- 总摄入热量: ${totalIntake} 千卡\n`;
        markdown += `- 总消耗热量: ${totalBurned} 千卡\n`;
        markdown += `- 净热量: ${netCalories} 千卡\n`;
      }

      // 创建并下载文件
      const blob = new Blob([markdown], { type: 'text/markdown' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `食物运动记录_${new Date().toISOString().slice(0, 10)}.md`;
      a.click();
      window.URL.revokeObjectURL(url);
    },

    exportAsExcel() {
      const { foods, exercises } = this.getFilteredData();

      // 创建工作簿
      const wb = XLSX.utils.book_new();

      // 准备食物数据
      if (foods.length > 0) {
        const foodData = [
          ['食物名称', '重量(g)', '热量(千卡)', '日期', '餐别']
        ];
        foods.forEach(food => {
          foodData.push([
            food.name,
            food.weight,
            food.calories,
            food.date,
            food.mealType
          ]);
        });

        const wsFoods = XLSX.utils.aoa_to_sheet(foodData);
        XLSX.utils.book_append_sheet(wb, wsFoods, '食物记录');
      }

      // 准备运动数据
      if (exercises.length > 0) {
        const exerciseData = [
          ['运动项目', '组数', '是否完成', '消耗热量', '日期']
        ];
        exercises.forEach(exercise => {
          const completedText = exercise.completed ? '是' : '否';
          exerciseData.push([
            exercise.name,
            exercise.sets,
            completedText,
            exercise.caloriesBurned,
            exercise.date
          ]);
        });

        const wsExercises = XLSX.utils.aoa_to_sheet(exerciseData);
        XLSX.utils.book_append_sheet(wb, wsExercises, '运动记录');
      }

      // 添加汇总表
      const summaryData = [
        ['项目', '数值'],
        ['总摄入热量', foods.reduce((sum, food) => sum + food.calories, 0)],
        ['总消耗热量', exercises.reduce((sum, exercise) => sum + (exercise.caloriesBurned || 0), 0)],
        ['净热量', foods.reduce((sum, food) => sum + food.calories, 0) - exercises.reduce((sum, exercise) => sum + (exercise.caloriesBurned || 0), 0)]
      ];

      const wsSummary = XLSX.utils.aoa_to_sheet(summaryData);
      XLSX.utils.book_append_sheet(wb, wsSummary, '汇总');

      // 导出文件
      XLSX.writeFile(wb, `食物运动记录_${new Date().toISOString().slice(0, 10)}.xlsx`);
    }
  }
}
</script>

<style scoped>
.export-data {
  margin-top: 20px;
}
</style>