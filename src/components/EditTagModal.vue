<template>
    <div class="modal modal-open">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" v-if="source._id">{{source._id}}</h5>
                    <button class="close" @click="close"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <form @submit.prevent="save">
                        <div class="form-row" v-if="tag && tag.parent">
                            <div class="col">
                                <label>
                                    Parent
                                    <input type="text" class="form-control" v-model="tag.parent" readonly="readonly">
                                </label>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="col">
                                <label>
                                    Name
                                    <input type="text" class="form-control" v-model="id">
                                </label>
                            </div>
                            <div class="col">
                                <label>
                                    Count
                                    <input type="number" class="form-control" v-model="count" step="1">
                                </label>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary" @click="save">Save</button>
                    <button type="button" class="btn btn-secondary" @click="close">Close</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import {store} from './../store/store';

    export default {
        store,
        name: "edit-tag-modal",
        props: {
            source: {
                type: Object
            }
        },
        data() {
            const {_id, count} = (this.source || {});
            return {id: _id, count: count || 1};
        },
        asyncComputed: {
            tag() {
                return this.$store.getters
                    .getTag(this.source._id)
                    .catch(err => ({...this.source}));
            }
        },
        methods: {
            close() {
                this.$store.commit('setEditing', null);
            },
            save() {
                this.$store
                    .dispatch('persistTag', {
                        _id: this.id,
                        oldId: this.tag._id || this._id,
                        parent: this.tag.parent,
                        count: parseInt(this.count, 10)
                    })
                    .then(() => this.close());
            }
        }
    };
</script>

<style scoped>
    div.modal.modal-open {
        display: block;
    }
</style>
