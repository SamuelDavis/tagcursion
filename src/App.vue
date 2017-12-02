<template>
    <div id="id">
        <tag v-for="(tag, i) in tags" v-bind:key="i" v-bind:tag="tag"></tag>
    </div>
</template>

<script>
    import Tag from './components/Tag';

    export default {
        name: 'app',
        components: {Tag},
        data() {
            return {
                tags: [{
                    name: 'Thud', children: [{
                        name: 'Etc', children: []
                    }]
                }, {
                    name: 'Grunt', children: [{
                        name: 'Foo', children: [{
                            name: 'Fiz', children: [],
                        }, {
                            name: 'Baz', children: []
                        }],
                    }, {
                        name: 'Bar', children: [{
                            name: 'Etc', children: []
                        }, {
                            name: 'Etc', children: []
                        }],
                    }, {
                        name: 'Qux', children: [],
                    }]
                }]
            };
        }
    };
</script>
