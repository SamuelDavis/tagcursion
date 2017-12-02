import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

function nullTag(_id, tags = []) {
    return tags.find(tag => tag._id === _id) || {_id, children: []};
}

function findRecursion(child, parent, tags) {
    if (child === parent) {
        return parent;
    }

    return nullTag(child, tags).children.reduce((recursion, otherChild) => {
        return recursion || findRecursion(otherChild, parent, tags);
    }, false);
}

export const store = new Vuex.Store({
    state: {
        tags: [
            // t1
            {_id: 'Thud', children: ['Etc']},
            {_id: 'Grunt', children: ['Foo', 'Bar']},
            // t2
            {_id: 'Foo', children: ['Fiz', 'Baz']},
            {_id: 'Bar', children: ['Etc', 'Etc']},
            {_id: 'Qux', children: []},
            // t3
            {_id: 'Fiz', children: []},
            {_id: 'Baz', children: []},
            {_id: 'Etc', children: []},
        ],
    },
    getters: {
        tagCounts({tags}) {
            return (_id = null) => {
                if (!_id) {
                    return tags.reduce((acc, {_id}) => {
                        acc[_id] = 1;
                        return acc;
                    }, {});
                }

                return nullTag(_id, tags).children.reduce((acc, child) => {
                    acc[child] = (acc[child] || 0) + 1;
                    return acc;
                }, {});
            };
        }
    },
    mutations: {
        addTag({tags}, {_id, parent, count = 1}) {
            const recursion = findRecursion(_id, parent, tags);
            if (recursion) {
                return alert(
                    recursion === _id
                        ? `Cannot make ${_id} a child of itself without infinite recursion.`
                        : `${_id} is a parent of ${recursion}, leading to infinite recursion.`
                );
            }
            if (!tags.find(tag => tag._id === _id)) {
                tags.push(nullTag(_id));
            }
            nullTag(parent, tags).children.push(...new Array(count).fill(_id));
        }
    }
});
