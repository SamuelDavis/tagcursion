import PouchDB from 'pouchdb';

const db = new PouchDB('tags');

export default class TagRepo {
    static fetch() {
        return db
            .allDocs({include_docs: true})
            .then(({rows}) => rows.map(({doc}) => doc));
    }

    static persist(tag) {
        return db.put(tag);
    }

    static onChange(cb) {
        db
            .changes({live: true, include_docs: true})
            .on('change', ({doc}) => cb(doc));
    }
}
