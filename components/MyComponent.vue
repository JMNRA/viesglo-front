<template>
  <div>
    <h1>My Component</h1>
  </div>

  <button @click="increment">Increment</button>
  <p>Count: {{ count }}</p>
</template>

<script setup>

const count = ref(0)

const increment = () => {
  count.value++
}



</script>

