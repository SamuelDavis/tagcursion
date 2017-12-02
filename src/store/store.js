import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export const store = new Vuex.Store({
    state: {
        tags: {
            // t1
            Thud: {name: 'Thud', children: ['Etc']},
            Grunt: {name: 'Grunt', children: ['Foo', 'Bar']},
            // t2
            Foo: {name: 'Foo', children: ['Fiz', 'Baz']},
            Bar: {name: 'Bar', children: ['Etc', 'Etc']},
            Qux: {name: 'Qux', children: []},
            // t3
            Fiz: {name: 'Fiz', children: []},
            Baz: {name: 'Baz', children: []},
            Etc: {name: 'Etc', children: []},
        },
    }
});
