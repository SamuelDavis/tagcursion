<template>
    <div id="id" class="container">
        <div class="row">
            <div class="col-xs-6">
                <tag></tag>
            </div>
            <div class="col-xs-6">

            </div>
        </div>
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
