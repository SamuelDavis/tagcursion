<template>
    <div id="app" class="container">
        <edit-tag-modal v-if="editing" :source="editing"></edit-tag-modal>
        <tag></tag>
        <tag v-for="_id in tags" :key="_id" :_id="_id"></tag>
    </div>
</template>

<script>
    import Tag from './Tag';
    import EditTagModal from './EditTagModal';
    import {store} from '../store/store';

    export default {
        store,
        name: 'app',
        components: {Tag, EditTagModal},
        computed: {
            tags() {
                return Object.keys(this.$store.state.tags);
            },
            editing() {
                return this.$store.state.editingTag;
            }
        }
    };
</script>
