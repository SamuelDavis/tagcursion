<template>
    <div id="id">
        <tag v-for="(tag, name) in tags" v-bind:key="name" v-bind:tag="tag"></tag>
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
            tags() {
                return this.$store.state.tags;
            }
        }
    };
</script>
