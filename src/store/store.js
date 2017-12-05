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
        editingTag: null,
        tags: []
    },
    mutations: {
        setTags(state, tags) {
            state.tags = tags;
        },
        setEditing(state, editingTag) {
            state.editingTag = editingTag;
        }
    },
    getters: {
        getTag() {
            return _id => TagRepo.fetchById(_id);
        },
        getTags() {
            return () => TagRepo.fetchAll();
        },
        countDescendants() {
            return _id => TagRepo
                .fetchAll()
                .then(tags => {
                    function recurseCountChildren(_id, counts = {}) {
                        return findChildren(_id, tags).reduce((counts, childId) => {
                            counts[childId] = (counts[childId] || 0) + 1;
                            return recurseCountChildren(childId, counts);
                        }, counts);
                    }

                    return recurseCountChildren(_id);
                });
        }
    },
    actions: {
        persistTag(context, {_id, oldId = null, parent = null, count = null}) {
            return TagRepo.edit(_id, oldId, parent, count);
        },
        removeTag(context, {_id, parent = null}) {
            return TagRepo.delete(_id, parent);
        }
    }
});

TagRepo.onChange(changes => TagRepo.fetchRaw().then(raw => store.commit('setTags', raw)));
TagRepo
    .fetchRaw()
    .then(raw => store.commit('setTags', raw));

