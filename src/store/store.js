import Vue from 'vue';
import Vuex from 'vuex';
import TagRepo from './services/TagRepo';

Vue.use(Vuex);

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
            return _id => Promise.resolve(
                _id
                    ? ((tags.find(tag => tag._id === _id) || {}).children || []).map(id => tags.find(tag => tag._id === id))
                    : tags
            );
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

