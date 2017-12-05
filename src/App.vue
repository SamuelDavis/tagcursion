<template>
    <div id="app" class="container">
        <edit-tag-modal></edit-tag-modal>
        <tag></tag>
    </div>
</template>

<script>
    import Tag from './components/Tag';
    import EditTagModal from './components/EditTagModal';
    import {store} from './store/store';

    export default {
        store,
        name: 'app',
        components: {Tag, EditTagModal}
    };
</script>
