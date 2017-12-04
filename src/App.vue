<template>
    <div id="id" class="container">
        <tag></tag>
    </div>
</template>

<script>
    import Tag from './components/Tag';
    import {store} from './store/store';

    export default {
        store,
        name: 'app',
        components: {Tag}
    };
</script>
