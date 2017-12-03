<template>
    <span>
    <div class="card" v-bind:style="style">
        <div class="card-body">
            {{model._id}}
            <span v-if="count > 1">({{count}})</span>
            <span v-html="addChildIcon" v-on:click="addChild"></span>
            <span v-html="removeTagIcon" v-if="model._id" v-on:click="removeTag"></span>
            <span v-if="expandedIcon" v-html="expandedIcon" v-on:click="toggle">Test</span>
        </div>
    </div>
        <tag v-if="expanded" v-for="(tag, i) in children"
             :key="tag.model._id"
             :model="tag.model"
             :count="tag.count"
             :parent="model._id"
             :depth="depth - i - 1"
             :parentCount="parentCount + 1"
        ></tag>
    </span>
</template>

<script>
    import {store} from './../store/store';
    import octicons from 'octicons';

    export default {
        store,
        name: "tag",
        props: {
            count: {
                type: Number,
                default: 1
            },
            parentCount: {
                type: Number,
                default: 0
            },
            depth: {
                type: Number,
                default: 0
            },
            parent: {
                type: String,
                default: null
            },
            model: {
                type: Object,
                default() {
                    return {
                        _id: null,
                        children: []
                    };
                }
            }
        },
        data() {
            return {
                expanded: false
            };
        },
        computed: {
            removeTagIcon() {
                return octicons.dash.toSVG();
            },
            addChildIcon() {
                return octicons.plus.toSVG();
            },
            expandedIcon() {
                return this.children.length && octicons[`triangle-${this.expanded ? 'down' : 'right'}`].toSVG();
            },
            style() {
                return {
                    'margin-left': `${this.parentCount * 2}vw`
                };
            }
        },
        asyncComputed: {
            children: {
                default: [],
                get() {
                    return this.$store.getters
                        .getTags(this.model._id)
                        .then(tags => {
                            return Object.values(tags.reduce((acc, tag) => {
                                acc[tag._id] = acc[tag._id] || {model: tag, count: 0};
                                acc[tag._id].count++;
                                return acc;
                            }, {}));
                        });
                }
            }
        },
        methods: {
            toggle() {
                this.expanded = !this.expanded;
            },
            addChild() {
                const [_id, count = 1] = (prompt('Name?') || '')
                    .split('|')
                    .map(value => value.trim());
                if (_id) {
                    this.$store
                        .dispatch('addTag', {_id, parent: this.model._id, count: parseInt(count, 10)})
                        .then(res => this.expanded = true);
                }
            },
            removeTag() {
                this.$store.dispatch('removeTag', {_id: this.model._id, parent: this.parent});
            }
        }
    };
</script>
