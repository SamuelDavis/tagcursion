<template>
    <div>
        <div class="card" v-bind:style="style" @mouseover="focused=true" @mouseout="focused=false">
            <div class="card-header" v-if="model._id">
                {{model._id}} <span v-if="count > 1">({{count}})</span>
            </div>
            <div class="card-body">
                <button class="btn btn-info" v-if="model._id" @click="editTag">Edit</button>
                <button class="btn btn-primary" @click="addChild">Add</button>
                <button class="btn btn-danger" v-if="model._id" @click="removeTag">Del</button>
                <button class="btn btn-info" v-if="children.length" @click="toggle">
                    {{expanded ? 'v' : '>'}}
                </button>
            </div>
            <div class="card-body" v-if="focused && Object.keys(descendants).length">
                <ul class="list-group">
                    <li class="list-group-item" v-for="(count, descendant) in descendants">
                        {{descendant}} ({{count}})
                    </li>
                </ul>
            </div>
        </div>
        <tag v-if="expanded" v-for="(tag, i) in children"
             :key="tag.model._id"
             :model="tag.model"
             :count="tag.count"
             :parent="model._id"
             :depth="depth - i - 1"
             :parentCount="parentCount + 1"></tag>
    </div>
</template>

<script>
    import {store} from './../store/store';

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
                expanded: false,
                focused: false
            };
        },
        computed: {
            style() {
                return {
                    'margin-left': `${this.parentCount * 10}vw`
                };
            }
        },
        asyncComputed: {
            children: {
                default: [],
                get() {
                    return this.$store.getters
                        .getTags(this.model._id)
                        .then(tags => Object.values(tags.reduce((acc, tag) => {
                            acc[tag._id] = acc[tag._id] || {model: tag, count: 0};
                            acc[tag._id].count++;
                            return acc;
                        }, {})));
                }
            },
            descendants: {
                default: {},
                get() {
                    return this.$store.getters.countDescendants(this.model._id);
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
            editTag() {
                const [_id, count = 1] = (prompt('Name?', `${this.model._id}|${this.count}`) || '')
                    .split('|')
                    .map(value => value.trim());
                if (_id) {
                    this.$store
                        .dispatch('editTag', {
                            _id: this.model._id,
                            newId: _id,
                            parent: this.parent,
                            count: parseInt(count, 10)
                        });
                }
            },
            removeTag() {
                this.$store.dispatch('removeTag', {_id: this.model._id, parent: this.parent});
            }
        }
    };
</script>
