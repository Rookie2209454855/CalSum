<template>
  <div class="food-input">
    <form @submit.prevent="addFood">
      <input v-model="foodName" placeholder="Food Name" required />
      <input type="number" v-model="grams" placeholder="Grams" required />
      <input type="number" v-model="caloriesPerGram" placeholder="Calories per Gram" required />
      <input type="date" v-model="date" required />
      <select v-model="mealType">
        <option value="breakfast">Breakfast</option>
        <option value="lunch">Lunch</option>
        <option value="dinner">Dinner</option>
      </select>
      <button type="submit">Add Food</button>
    </form>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      foodName: '',
      grams: 0,
      caloriesPerGram: 0,
      date: '',
      mealType: ''
    };
  },
  methods: {
    addFood() {
      axios.post('/add', {
        name: this.foodName,
        grams: this.grams,
        calories_per_gram: this.caloriesPerGram,
        date: this.date,
        mealType: this.mealType
      }).then(response => {
        console.log(response.data);
        // Optionally update the food list or show a success message
      });
    }
  }
};
</script>
