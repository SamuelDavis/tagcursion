<template>
    <div id="id">
        <tag v-for="child in children" v-bind:key="child._id" v-bind:_id="child._id" v-bind:count="child.count"
             v-bind:z="child.z"></tag>
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
                const children = this.$store.getters.tagCounts(this._id);
                const length = Object.values(children).length;
                return Object.keys(children).map((_id, i) => ({
                    _id,
                    z: length - i,
                    count: children[_id]
                }));
            }
        }
    };
</script>
