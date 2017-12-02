<template>
    <ul class="deck">
        <li class="card" v-bind:class="{selected:selected}" v-on:dblclick="addChild" v-on:click="select">
            {{_id}} <span v-if="count > 1">({{count}})</span>
        </li>
        <li v-for="(count, _id) in children" :key="_id">
            <tag :count="count" :_id="_id"></tag>
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
                return this.$store.getters.tagCounts(this._id);
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
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);
        padding: 2px 16px;
        float: left;
        clear: both;
        transition: 0.3s;
        border: 1px solid black;
        border-radius: 3px;
        background: antiquewhite;
    }

    .card:hover {
        box-shadow: 0 8px 16px 0 rgba(0, 0, 0, 0.4);
    }
</style>
