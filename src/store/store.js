import Vue from 'vue';
import Vuex from 'vuex';
import TagRepo from './services/TagRepo';

Vue.use(Vuex);

function findTag(_id, tags) {
    return tags.find(tag => tag._id === _id);
}

function findChildren(_id, tags) {
    return (findTag(_id, tags) || {}).children || [];
}

export const store = new Vuex.Store({
    state: {
        revision: null,
        tags: []
    },
    mutations: {
        setTags(state, tags) {
            state.tags = tags;
        }
    },
    getters: {
        getTags({tags}) {
            return _id => {
                return Promise.resolve(_id ? findChildren(_id, tags).map(id => findTag(id, tags)) : tags);
            };
        },
        countDescendants({tags}) {
            return _id => {
                function recurseCountChildren(_id, counts = {}) {
                    return findChildren(_id, tags).reduce((counts, childId) => {
                        counts[childId] = (counts[childId] || 0) + 1;
                        return recurseCountChildren(childId, counts);
                    }, counts);
                }

                const counts = recurseCountChildren(_id);

                return Promise.resolve(counts);
            };
        }
    },
    actions: {
        addTag(context, {_id, parent = null, count = 1}) {
            return TagRepo.persist(_id, parent, count);
        },
        editTag(context, {_id, newId = null, parent = null, count = null}) {
            return TagRepo.edit(_id, newId, parent, count);
        },
        removeTag(context, {_id, parent = null}) {
            return TagRepo.delete(_id, parent);
        }
    }
});

TagRepo.onChange(change => TagRepo
    .fetchAll()
    .then(tags => store.commit('setTags', tags)));
TagRepo
    .fetchAll()
    .then(tags => store.commit('setTags', tags));

