import PouchDB from 'pouchdb';

const db = new PouchDB('tags');

export default class TagRepo {
    static onChange(cb) {
        return db
            .changes({
                since: 'now',
                live: true,
                include_docs: true
            })
            .on('change', cb);
    }

    static fetchAll(keys = undefined) {
        return db
            .allDocs({include_docs: true, keys})
            .then(({rows}) => rows.map(({doc}) => doc));
    }

    static fetchById(_id) {
        return db.get(_id);
    }

    static persist(_id, parent = null, count = 1, setCount = false) {
        if (parent) {
            return this
                .persist(_id)
                .then(tag => this.fetchById(parent)
                    .then(parent => {
                        const children = parent.children.filter(child => child === _id).length;
                        count = Math.max(0, setCount ? count : children + count);
                        parent.children = parent.children.filter(child => child !== _id);
                        parent.children.push(...new Array(count).fill(_id));
                        return db.put(parent);
                    })
                    .then(parent => tag));
        }
        return this
            .fetchById(_id)
            .catch(err => db.put({_id, children: []}));
    }

    static changeId(oldId, newId) {
        if (oldId === newId) {
            return Promise.resolve(newId);
        }

        return this
            .persist(newId)
            .then(tag => this.fetchAll())
            .then(tags => db.bulkDocs(tags.map(tag => {
                const count = tag.children.filter(child => child === oldId).length;
                tag.children.push(...new Array(count).fill(newId));
                return tag;
            })))
            .then(tags => this.delete(oldId))
            .then(res => newId);
    }

    static edit(_id, newId = undefined, parent = undefined, count = undefined) {
        return this
            .changeId(_id, newId)
            .then(id => (parent !== undefined && count !== undefined) ? this.persist(id, parent, count, true) : id);
    }

    static delete(_id, parent = null) {
        if (parent) {
            return this
                .fetchById(parent)
                .then(parent => {
                    parent.children.splice(parent.children.indexOf(_id), 1);
                    return db.put(parent);
                });
        }
        return this
            .fetchAll()
            .then(tags => db.bulkDocs(tags.map(parent => {
                parent.children = parent.children.filter(child => child !== _id);
                return parent;
            })))
            .then(tags => this.fetchById(_id))
            .then(tag => db.remove(tag));

    }
}
