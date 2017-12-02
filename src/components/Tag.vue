<template>
    <ul class="deck">
        <li class="card">{{tag.name}} <span v-if="count > 1">({{count}})</span></li>
        <li v-for="(child, i) in uniqueChildren" :key="i">
            <tag :tag="child.tag" :count="child.count"></tag>
        </li>
    </ul>
</template>

<script>
    export default {
        name: "tag",
        props: {
            tag: Object,
            count: {
                type: Number,
                default: 1
            }
        },
        computed: {
            uniqueChildren: function () {
                const children = this.tag.children.reduce((acc, tag) => {
                    acc[tag.name] = acc[tag.name] || {
                        tag, count: 0
                    };
                    acc[tag.name].count++;
                    return acc;
                }, {});

                return Object.values(children);
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
