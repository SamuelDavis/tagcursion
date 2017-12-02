<template>
    <div id="id">
        <tag v-for="(count, _id) in children" v-bind:key="_id" v-bind:_id="_id" v-bind:count="count"></tag>
    </div>
</template>

<script>
    import Tag from './components/Tag';
    import {store} from './store/store';

    export default {
        store,
        name: 'app',
        components: {Tag},
        computed: {
            children() {
                return this.$store.getters.tagCounts();
            }
        }
    };
</script>
