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

    static persist(_id, parent = null, count = 1) {
        if (parent) {
            return this
                .persist(_id)
                .then(tag => this.fetchById(parent)
                    .then(parent => {
                        parent.children.push(...new Array(count).fill(_id));
                        return db.put(parent);
                    })
                    .then(parent => tag));
        }
        return this
            .fetchById(_id)
            .catch(err => db.put({_id, children: []}));
    }

    static delete(_id, parent = null) {
        if (parent) {
            return this
                .fetchById(parent)
                .then(parent => {
                    parent.children.splice(parent.children.indexOf(_id), 1);
                    return db.put(parent);
                })
                .catch(err => log(err, arguments));
        }
        return this
            .fetchById(_id)
            .then(tag => db.remove(tag))
            .then(res => this.fetchAll()
                .then(tags => db.bulkDocs(tags.map(tag => ({
                    ...tag,
                    children: tag.children.filter(child => child === tag)
                })))));
    }
}
