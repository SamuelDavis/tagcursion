<template>
    <ul class="deck">
        <li class="card"
            v-bind:style="{'z-index':z}"
            v-bind:class="{selected:selected}"
            v-on:dblclick="addChild"
            v-on:click="select">
            {{_id}} <span v-if="count > 1">({{count}})</span>
        </li>
        <li v-for="child in children" :key="child._id">
            <tag v-bind:z="child.z" :count="child.count" :_id="child._id"></tag>
        </li>
    </ul>
</template>

<script>
    import {store} from './../store/store';

    export default {
        store,
        name: "tag",
        props: {
            _id: String,
            z: {
                type: Number,
                default: 0
            },
            count: {
                type: Number,
                default: 1
            }
        },
        computed: {
            selected() {
                return this.$store.state.selected === this._id;
            },
            children() {
                const children = this.$store.getters.tagCounts(this._id);
                return Object.keys(children).map((_id, i) => {
                    return {
                        _id,
                        z: this.z - 1 - i,
                        count: children[_id]
                    };
                });
            }
        },
        methods: {
            select() {
                this.$store.commit('setSelected', {selected: this._id});
            },
            addChild() {
                let [_id, count] = (prompt('Name?') || '').split('|');
                _id = _id.trim();
                count = parseInt(count, 10) || 1;

                if (_id) {
                    this.$store.commit('addTag', {_id, parent: this._id, count});
                }
            }
        }
    };
</script>

<style scoped>
    .selected {
        background-color: lightgreen;
    }
</style>

<style>
    .deck {
        list-style: none;
    }

    .card {
        position: relative;
        margin-bottom: -3px;
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.4);
        padding: 2px 16px;
        float: left;
        clear: both;
        transition: 0.3s;
        border: 1px solid black;
        border-radius: 3px;
        background: antiquewhite;
    }

    .card:hover {
        box-shadow: 0 8px 16px 0 rgba(0, 0, 0, 0.8);
        z-index: 999 !important;
    }
</style>
