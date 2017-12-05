<template>
    <div v-if="tag" class="modal modal-open">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" v-if="tag.model._id">{{tag.model._id}}</h5>
                    <button class="close" @click="close"><span>&times;</span></button>
                </div>
                <div class="modal-body">
                    <form>
                        <div class="form-row" v-if="tag.parent">
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
                    <button type="button" class="btn btn-primary" @click="save">Save</button>
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
        data() {
            return {
                id: '_test_',
                count: 1
            };
        },
        asyncComputed: {
            tag() {
                return Promise
                    .resolve(this.$store.state.editingTag)
                    .then(tag => {
                        if (tag) {
                            this.id = tag.model._id;
                            this.count = tag.count;
                        }
                        return tag;
                    });
            }
        },
        methods: {
            close() {
                this.$store.commit('setEditing', null);
            },
            save() {
                this.$store
                    .dispatch('editTag', {
                        _id: this.tag.model._id || this.id,
                        newId: this.id,
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
