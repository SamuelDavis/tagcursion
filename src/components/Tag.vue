<template>
    <ul class="deck">
        <li class="card">{{tag.name}} <span v-if="count > 1">({{count}})</span></li>
        <li v-for="(child, name) in children" :key="name">
            <tag :count="child.count" :tag="child.tag"></tag>
        </li>
    </ul>
</template>

<script>
    import {store} from './../store/store';

    export default {
        store,
        name: "tag",
        props: {
            tag: {
                type: Object,
                default: {
                    name: '???',
                    children: []
                }
            },
            count: {
                type: Number,
                default: 1
            }
        },
        data() {
            return {active: false};
        },
        computed: {
            children() {
                return this.tag.children.reduce((acc, name) => {
                    acc[name] = acc[name] || {
                        tag: this.$store.state.tags[name],
                        count: 0
                    };
                    acc[name].count++;
                    return acc;
                }, {});
            }
        }
    };
</script>

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
