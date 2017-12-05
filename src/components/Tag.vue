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
                <button class="btn btn-info" v-if="model.children.length" @click="toggle">
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
        <tag v-if="expanded" v-for="(child, i) in childAggregate"
             :key="child._id"
             :_id="child._id"
             :depth="depth - i - 1"
             :count="child.count"
             :parent="model._id"
             :parentCount="parentCount + 1"
        ></tag>
    </div>
</template>

<script>
    import {store} from './../store/store';

    export default {
        store,
        name: "tag",
        props: {
            _id: {
                type: String,
                default: null
            },
            depth: {
                type: Number,
                default: 0
            },
            count: {
                type: Number,
                default: 1
            },
            parent: {
                type: String,
                default: null
            },
            parentCount: {
                type: Number,
                default: 0
            }
        },
        data() {
            return {
                expanded: false,
                focused: false,
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
            model: {
                default: {_id: null, _rev: null, children: []},
                get() {
                    return this.$store.getters
                        .getTag(this._id)
                        .catch(err => ({_id: null, _rev: null, children: []}));
                }
            },
            childAggregate: {
                default: [],
                get() {
                    return Object.values(this.model.children.reduce((aggregate, _id) => {
                        aggregate[_id] = aggregate[_id] || {_id, count: 0};
                        aggregate[_id].count++;
                        return aggregate;
                    }, {}));
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
                this.$store.commit('setEditing', {
                    parent: this._id,
                    _id: null,
                    count: null
                });
            },
            editTag() {
                this.$store.commit('setEditing', {
                    parent: this.parent,
                    _id: this._id,
                    count: this.count
                });
            },
            removeTag() {
                this.$store.dispatch('removeTag', {_id: this.model._id, parent: this.parent});
            }
        }
    };
</script>
