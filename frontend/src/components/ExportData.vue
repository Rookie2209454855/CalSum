<template>
  <div class="export-data">
    <el-card class="export-card">
      <div slot="header" class="card-header">
        <span class="header-title">数据导出</span>
      </div>

      <!-- 桌面端布局 -->
      <el-form :inline="true" class="export-form desktop-layout">
        <el-form-item label="导出日期范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="yyyy-MM-dd"
            value-format="yyyy-MM-dd"
            style="width: 100%;">
          </el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="exportAsMarkdown">导出 Markdown</el-button>
          <el-button type="success" @click="exportAsExcel">导出 Excel</el-button>
        </el-form-item>
      </el-form>

      <!-- 移动端布局 -->
      <div class="mobile-layout">
        <el-form :model="dateRange" class="export-form" label-width="80px" size="small">
          <el-form-item label="日期范围">
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              format="yyyy-MM-dd"
              value-format="yyyy-MM-dd"
              style="width: 100%;">
            </el-date-picker>
          </el-form-item>
        </el-form>

        <div class="button-group">
          <el-button type="primary" @click="exportAsMarkdown" class="export-btn" icon="el-icon-document">
            <span class="btn-text">导出 Markdown</span>
          </el-button>
          <el-button type="success" @click="exportAsExcel" class="export-btn" icon="el-icon-document">
            <span class="btn-text">导出 Excel</span>
          </el-button>
        </div>
      </div>
    </el-card>
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

.export-card {
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.export-card:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.card-header {
  display: flex;
  align-items: center;
  padding: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px 12px 0 0;
}

.header-title {
  font-size: 16px;
  font-weight: 600;
  color: #ffffff;
}

.export-form .el-form-item {
  margin-bottom: 18px;
}

/* 桌面端布局 - 默认显示 */
.desktop-layout {
  display: flex;
  align-items: center;
}

/* 移动端布局 - 默认隐藏 */
.mobile-layout {
  display: none;
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .export-card {
    border-radius: 8px;
  }

  .export-card .el-card__header {
    padding: 12px 15px;
  }

  .export-card .el-card__body {
    padding: 15px;
  }

  /* 隐藏桌面布局 */
  .desktop-layout {
    display: none;
  }

  /* 显示移动端布局 */
  .mobile-layout {
    display: block;
  }

  .mobile-layout .export-form {
    margin-bottom: 15px;
  }

  .mobile-layout .export-form .el-form-item {
    display: block;
    margin-right: 0;
    margin-bottom: 15px;
  }

  .mobile-layout .export-form .el-form-item__label {
    width: 80px !important;
    font-size: 14px;
    line-height: 36px;
  }

  .mobile-layout .el-date-editor {
    width: 100%;
  }

  .mobile-layout .el-date-editor .el-input__inner {
    font-size: 16px;
    height: 36px;
    line-height: 36px;
  }

  .button-group {
    display: flex;
    gap: 10px;
  }

  .export-btn {
    flex: 1;
    height: 44px;
    font-size: 15px;
    font-weight: 500;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .export-btn:active {
    transform: scale(0.98);
  }

  .export-btn .btn-text {
    margin-left: 4px;
  }
}

@media screen and (max-width: 480px) {
  .export-card .el-card__body {
    padding: 12px;
  }

  .mobile-layout .export-form .el-form-item__label {
    width: 70px !important;
    font-size: 13px;
    line-height: 34px;
  }

  .mobile-layout .el-date-editor .el-input__inner {
    height: 34px;
    line-height: 34px;
  }

  .button-group {
    flex-direction: column;
    gap: 10px;
  }

  .export-btn {
    width: 100%;
    height: 42px;
    font-size: 14px;
  }
}

/* 超小屏手机适配 */
@media screen and (max-width: 360px) {
  .export-card .el-card__body {
    padding: 10px;
  }

  .mobile-layout .export-form .el-form-item__label {
    width: 65px !important;
  }

  .export-btn {
    height: 40px;
    font-size: 13px;
  }
}

/* 横屏模式优化 */
@media screen and (max-height: 500px) and (orientation: landscape) {
  .export-card .el-card__body {
    padding: 10px;
  }

  .button-group {
    flex-direction: row;
    gap: 8px;
  }

  .export-btn {
    height: 38px;
  }
}

/* 触控优化 */
@media (hover: none) and (pointer: coarse) {
  .export-btn {
    min-height: 48px;
  }

  .mobile-layout .el-date-editor .el-input__inner {
    padding-top: 6px;
    padding-bottom: 6px;
    min-height: 44px;
  }
}
</style>